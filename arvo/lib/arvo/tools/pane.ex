defmodule Arvo.Tools.Pane do
  @moduledoc """
  Run long-running or interactive work in a Herdr sibling pane (or labeled
  blocking bash outside Herdr).

  Modes:
  - `finite` — open → run → wait exit/match → capture → close
  - `long_lived` — open → run → wait running-state → leave pane open + registered
  """

  use Jido.Action,
    name: "pane",
    description:
      "Run a long-running or interactive command in a Herdr sibling pane the operator can watch and join. Use for servers, REPLs, debuggers, multi-minute jobs. Short one-shot shell commands should use bash instead. mode=finite waits for exit then closes the pane; mode=long_lived returns after a running-state signal and leaves the pane open until process exit, Esc, or HEAD jump. Outside Herdr, falls back to labeled blocking bash (no hidden background job).",
    category: "tools",
    tags: ["shell", "pane", "herdr"],
    vsn: "0.1.0",
    schema: [
      command: [type: :string, required: true, doc: "Shell command to run in the pane"],
      mode: [
        type: :string,
        required: false,
        doc: "finite (default) or long_lived"
      ],
      timeout: [
        type: :pos_integer,
        required: false,
        doc: "Timeout in seconds (default 300 finite / 30 long_lived wait)"
      ],
      wait_match: [
        type: :string,
        required: false,
        doc: "Substring to wait for in pane output before capture/return"
      ],
      direction: [
        type: :string,
        required: false,
        doc: "Split direction: right or down (default right)"
      ]
    ]

  @fallback_label "[arvo: no Herdr pane — ran as blocking bash]"

  @doc false
  def spec, do: Arvo.Tool.spec_from_jido(__MODULE__)

  @impl Jido.Action
  def run(params, ctx) do
    command = params[:command] || params["command"]
    mode = normalize_mode(params[:mode] || params["mode"])
    timeout_s = params[:timeout] || params["timeout"] || default_timeout(mode)
    wait_match = params[:wait_match] || params["wait_match"]
    direction = normalize_direction(params[:direction] || params["direction"])
    cwd = Map.get(ctx || %{}, :cwd) || Map.get(ctx || %{}, "cwd") || File.cwd!()

    if Arvo.Herdr.available?() do
      run_in_herdr(command, mode, timeout_s, wait_match, direction, cwd)
    else
      run_fallback_bash(command, mode, timeout_s, cwd)
    end
  end

  defp run_in_herdr(command, mode, timeout_s, wait_match, direction, cwd) do
    timeout_ms = timeout_s * 1000

    case Arvo.Herdr.split(direction: direction, no_focus: true, cwd: cwd) do
      {:ok, pane_id} ->
        case Arvo.Session.register_pane(%{
               pane_id: pane_id,
               mode: mode,
               command: command,
               # Reaper starts after running-state return for long_lived (KTD8).
               start_reaper: false
             }) do
          :ok -> :ok
          {:error, _} -> :ok
        end

        case Arvo.Herdr.run(pane_id, command) do
          :ok ->
            case mode do
              :finite ->
                finite_lifecycle(pane_id, command, timeout_ms, wait_match)

              :long_lived ->
                long_lived_lifecycle(pane_id, command, timeout_ms, wait_match)
            end

          {:error, msg} ->
            _ = cleanup_pane(pane_id)
            {:error, "pane run failed: #{msg}"}
        end

      {:error, msg} ->
        {:error, "pane split failed: #{msg}"}
    end
  end

  defp finite_lifecycle(pane_id, command, timeout_ms, wait_match) do
    wait_result = wait_for_signal(pane_id, timeout_ms, wait_match, :finite)

    read_text =
      case Arvo.Herdr.read(pane_id, lines: 200) do
        {:ok, t} -> t
        {:error, _} -> ""
      end

    close_status = cleanup_pane(pane_id)

    case wait_result do
      {:ok, _} ->
        body = format_capture(command, pane_id, read_text, :finished, close_status)
        {:ok, body}

      {:error, :timeout} ->
        body = format_capture(command, pane_id, read_text, :timeout, close_status)
        {:error, body}

      {:error, msg} ->
        body = format_capture(command, pane_id, read_text, :error, close_status)
        {:error, "#{body}\n[wait error: #{msg}]"}
    end
  end

  defp long_lived_lifecycle(pane_id, command, timeout_ms, wait_match) do
    _ = wait_for_signal(pane_id, timeout_ms, wait_match, :long_lived)

    read_text =
      case Arvo.Herdr.read(pane_id, lines: 100) do
        {:ok, t} -> t
        {:error, _} -> ""
      end

    # Leave pane open and registered; start reaper after running-state (KTD8).
    _ =
      try do
        Arvo.Session.ensure_pane_reaper(pane_id)
      catch
        :exit, _ -> :ok
      end

    body =
      """
      [pane started — long_lived]
      pane_id: #{pane_id}
      command: #{command}
      status: running (pane remains open for operator join)
      --- output ---
      #{String.trim_trailing(read_text)}
      """
      |> String.trim()

    {:ok, body}
  end

  defp wait_for_signal(pane_id, timeout_ms, wait_match, mode) do
    cond do
      is_binary(wait_match) and wait_match != "" ->
        case Arvo.Herdr.wait_output(pane_id,
               match: wait_match,
               timeout: timeout_ms
             ) do
          {:ok, _} = ok ->
            ok

          {:error, msg} ->
            cond do
              mode == :long_lived ->
                # Best-effort started if match never appears
                {:ok, :best_effort}

              String.contains?(to_string(msg), "timed out") ->
                {:error, :timeout}

              true ->
                {:error, msg}
            end
        end

      mode == :long_lived ->
        # Brief settle then treat as started
        Process.sleep(min(timeout_ms, 200))
        {:ok, :started}

      true ->
        wait_process_exit(pane_id, timeout_ms)
    end
  end

  # Grace before treating shell-only as exit (avoids mid-spawn false exit).
  @exit_grace_ms 500

  defp wait_process_exit(pane_id, timeout_ms) do
    now = System.monotonic_time(:millisecond)
    deadline = now + timeout_ms
    do_wait_exit(pane_id, deadline, now, false)
  end

  defp do_wait_exit(pane_id, deadline, started_at, seen_work?) do
    now = System.monotonic_time(:millisecond)

    if now >= deadline do
      {:error, :timeout}
    else
      case Arvo.Herdr.process_info(pane_id) do
        {:ok, info} ->
          cond do
            not Arvo.Herdr.process_exited?(info) ->
              # Slow down after first non-shell sighting to cut process_info forks.
              Process.sleep(if(seen_work?, do: 500, else: 200))
              do_wait_exit(pane_id, deadline, started_at, true)

            seen_work? ->
              # Saw a non-shell process, now back to shell-only → finished.
              {:ok, :exited}

            now - started_at < @exit_grace_ms ->
              # Still in start grace; shell-only may mean not yet launched.
              Process.sleep(100)
              do_wait_exit(pane_id, deadline, started_at, seen_work?)

            true ->
              # Past grace, never saw work: command likely finished instantly.
              {:ok, :exited}
          end

        {:error, _} ->
          # Pane missing — treat as done
          {:ok, :gone}
      end
    end
  end

  defp cleanup_pane(pane_id) do
    status =
      case Arvo.Herdr.close(pane_id) do
        :ok -> :closed
        {:error, _} -> :close_error
      end

    _ =
      try do
        Arvo.Session.unregister_pane(pane_id)
      catch
        :exit, _ -> :ok
      end

    status
  end

  defp run_fallback_bash(command, mode, timeout_s, cwd) do
    timeout_ms = timeout_s * 1000

    header =
      case mode do
        :long_lived ->
          "#{@fallback_label}\n[long_lived outside Herdr: blocks until exit/timeout — not a live pane]\n"

        _ ->
          "#{@fallback_label}\n"
      end

    case Arvo.Tools.Bash.run_command(command, cwd, timeout_ms) do
      {:ok, {output, exit_code}} ->
        body = header <> format_bash_output(output, exit_code)

        if exit_code == 0 do
          {:ok, body}
        else
          {:error, body}
        end

      {:error, :timeout} ->
        {:error, header <> "Command timed out after #{timeout_s}s: #{command}"}

      {:error, reason} ->
        {:error, header <> "Failed to run command: #{inspect(reason)}"}
    end
  end

  defp format_bash_output(output, exit_code) do
    status = if exit_code == 0, do: "", else: "\n[exit code #{exit_code}]"
    String.trim_trailing(output) <> status
  end

  defp format_capture(command, pane_id, text, outcome, close_status) do
    """
    [pane #{outcome}]
    pane_id: #{pane_id}
    command: #{command}
    close: #{close_status}
    --- output ---
    #{String.trim_trailing(text)}
    """
    |> String.trim()
  end

  defp normalize_mode(mode), do: Arvo.Herdr.normalize_mode(mode)

  defp default_timeout(:long_lived), do: 30
  defp default_timeout(_), do: 300

  defp normalize_direction("down"), do: :down
  defp normalize_direction(:down), do: :down
  defp normalize_direction(_), do: :right
end
