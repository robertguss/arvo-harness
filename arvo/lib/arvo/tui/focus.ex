defmodule Arvo.TUI.Focus do
  @moduledoc """
  Raw-mode Focus product surface (prototype variant D).

  Owns the terminal: ghost strip + transcript + input + footer.
  Dispatches input → Session.start_turn / cancel_turn / slash — never Agent.run.
  Falls back to a line-mode loop when Termite cannot start (non-TTY / tests).
  """

  alias Arvo.TUI.Render

  @doc """
  Run the Focus UI until quit.

  Options:
  - `:mode` — `:raw` (default when TTY) or `:line` (IO.gets fallback)
  - `:device` — IO device for line mode (default `:stdio`)
  """
  def run(opts \\ []) do
    mode = Keyword.get(opts, :mode) || default_mode()

    case mode do
      :raw -> run_raw(opts)
      :line -> run_line(Keyword.get(opts, :device, :stdio))
    end

    # Product path runs under `mix run --no-halt`. Leaving after Focus returns
    # without stopping the VM leaves a zombie BEAM with no UI (same as Repl).
    # Tests set `:halt_on_focus_quit` false (see config/config.exs :test).
    halt_after_focus()
    :ok
  end

  defp halt_after_focus do
    if Application.get_env(:arvo, :halt_on_focus_quit, true) do
      fun = Application.get_env(:arvo, :focus_halt_fun, &System.stop/1)
      fun.(0)
    end
  end

  defp default_mode do
    if Application.get_env(:arvo, :focus_mode) do
      Application.get_env(:arvo, :focus_mode)
    else
      case :io.getopts(:standard_io) do
        list when is_list(list) ->
          if Keyword.get(list, :terminal, false) or is_tty?(), do: :raw, else: :line

        _ ->
          if is_tty?(), do: :raw, else: :line
      end
    end
  end

  defp is_tty? do
    case System.cmd("test", ["-t", "0"], stderr_to_stdout: true) do
      {_, 0} -> true
      _ -> false
    end
  rescue
    _ -> false
  end

  defp run_raw(_opts) do
    term = Termite.Terminal.start()

    term =
      term
      |> Termite.Screen.alt_screen()
      |> Termite.Screen.clear_screen()
      |> Termite.Terminal.write(Termite.Screen.escape_sequence(:cursor_hide))

    try do
      raw_loop(term, %{input: "", multiline: false, scroll: 0, palette: nil}, nil)
    after
      try do
        term
        |> Termite.Terminal.write(Termite.Screen.escape_sequence(:cursor_show))
        |> Termite.Screen.exit_alt_screen()
      rescue
        _ -> :ok
      end
    end
  end

  # Paint only when the frame changes. Full clear_screen on every 80ms poll was
  # causing continuous flicker (shaky/jittery UI) even when idle.
  defp raw_loop(term, local, last_frame) do
    st = Arvo.TUI.state()
    # Stick to live tail while the agent is streaming/working so scroll-back
    # does not freeze the user on a stale viewport mid-turn.
    local =
      if st.status == :running and local.scroll != 0 do
        %{local | scroll: 0}
      else
        local
      end

    st =
      st
      |> Map.put(:input, local.input)
      |> Map.put(:scroll, local.scroll)
      |> Map.put(:palette, local[:palette])

    {w, h} = size(term)
    frame = Render.frame(st, width: w, height: h, scroll: local.scroll)

    {term, last_frame} =
      if frame == last_frame do
        {term, last_frame}
      else
        {paint_frame(term, frame), frame}
      end

    case Termite.Terminal.poll(term, 80) do
      :timeout ->
        raw_loop(term, local, last_frame)

      {:data, data} when is_binary(data) ->
        case handle_keys(data, local, st) do
          {:quit, _} ->
            :ok

          {:cont, local2} ->
            raw_loop(term, local2, last_frame)
        end

      other ->
        # Unknown message — keep looping
        _ = other
        raw_loop(term, local, last_frame)
    end
  end

  # Home cursor + overwrite (no screen_clear). Frame lines include EL so short
  # lines do not leave ghost glyphs from the previous paint.
  defp paint_frame(term, frame) when is_binary(frame) do
    el = Termite.Screen.escape_code() <> "K"

    painted =
      frame
      |> String.split("\n")
      |> Enum.map_join("\n", fn line -> line <> el end)

    term
    |> Termite.Screen.cursor_position(1, 1)
    |> Termite.Terminal.write(painted)
  end

  defp size(%{size: %{width: w, height: h}}) when is_integer(w) and is_integer(h), do: {w, h}
  defp size(_), do: {80, 24}

  defp handle_keys(data, local, st) do
    tree_open? = st[:tree] != nil

    cond do
      # Esc: tree → palette → cancel turn
      data == "\e" or data == "\e\e" ->
        cond do
          tree_open? ->
            _ = Arvo.TUI.key(:esc)
            {:cont, local}

          local[:palette] != nil ->
            {:cont, %{local | palette: nil}}

          st.status == :running ->
            _ = Arvo.TUI.key(:esc)
            {:cont, local}

          true ->
            {:cont, local}
        end

      # Ctrl+E — global expand/collapse (not while tree open)
      data == "\x05" and not tree_open? ->
        _ = Arvo.TUI.key(:ctrl_e)
        {:cont, local}

      # Up / Down — tree > palette > transcript focus
      data in ["\e[A", "\eOA"] ->
        cond do
          tree_open? ->
            _ = Arvo.TUI.key(:up)
            {:cont, local}

          local[:palette] ->
            {:cont, move_palette_sel(local, :up)}

          true ->
            _ = Arvo.TUI.key(:up)
            {:cont, local}
        end

      data in ["\e[B", "\eOB"] ->
        cond do
          tree_open? ->
            _ = Arvo.TUI.key(:down)
            {:cont, local}

          local[:palette] ->
            {:cont, move_palette_sel(local, :down)}

          true ->
            _ = Arvo.TUI.key(:down)
            {:cont, local}
        end

      # PageUp / Ctrl+Up — scroll transcript toward older lines
      data in ["\e[5~", "\e[1;5A"] and not tree_open? ->
        {:cont, %{local | scroll: local.scroll + scroll_step()}}

      # PageDown / Ctrl+Down — toward live tail
      data in ["\e[6~", "\e[1;5B"] and not tree_open? ->
        {:cont, %{local | scroll: max(local.scroll - scroll_step(), 0)}}

      data in ["\r", "\n"] ->
        if tree_open? do
          _ = Arvo.TUI.key(:enter)
          {:cont, %{local | input: "", palette: nil}}
        else
          submit_input(local, st)
        end

      # Space toggles focus row when input empty and idle
      data == " " and String.trim(local.input) == "" and st.status != :running and
          local[:palette] == nil and not tree_open? ->
        _ = Arvo.TUI.key(:space)
        {:cont, local}

      data == "\x7f" or data == "\b" ->
        if tree_open? do
          {:cont, local}
        else
          input = String.slice(local.input, 0..-2//1)
          {:cont, set_input(local, input)}
        end

      data == "\x03" ->
        # Ctrl+C
        {:quit, local}

      String.printable?(data) and not String.contains?(data, "\e") and not tree_open? ->
        input = local.input <> data
        {:cont, set_input(local, input)}

      true ->
        {:cont, local}
    end
  end

  defp scroll_step, do: 10

  defp set_input(local, input) do
    palette =
      if String.starts_with?(input, "/") do
        q = input |> String.trim_leading("/") |> String.split(" ", parts: 2) |> hd()
        sel = (local[:palette] || %{})[:selected] || 0
        items = Arvo.TUI.SlashMenu.filter(q)
        %{query: q, selected: Arvo.TUI.SlashMenu.clamp_selected(items, sel)}
      else
        nil
      end

    %{local | input: input, palette: palette}
  end

  defp move_palette_sel(local, dir) do
    pal = local[:palette] || %{query: "", selected: 0}
    items = Arvo.TUI.SlashMenu.filter(pal[:query] || "")
    sel = pal[:selected] || 0

    sel2 =
      case dir do
        :up -> max(sel - 1, 0)
        :down -> min(sel + 1, max(length(items) - 1, 0))
      end

    %{local | palette: %{pal | selected: sel2}}
  end

  defp submit_input(local, st) do
    # Palette Enter: complete to selected command (keep trailing args if any)
    local =
      if local[:palette] do
        case selected_palette_cmd(local) do
          nil ->
            %{local | palette: nil}

          name ->
            draft = String.trim(local.input)

            args =
              case String.split(String.trim_leading(draft, "/"), " ", parts: 2) do
                [_, a] -> " " <> a
                _ -> ""
              end

            %{local | input: "/" <> name <> args, palette: nil}
        end
      else
        local
      end

    text = String.trim(local.input)

    cond do
      text == "" and st.status != :running ->
        # Empty Enter toggles focused row when idle
        _ = Arvo.TUI.key(:enter)
        {:cont, local}

      text == "" ->
        {:cont, local}

      text in ["quit", "exit"] ->
        {:quit, local}

      String.starts_with?(text, "/") ->
        case Arvo.TUI.Commands.parse(text) do
          {:command, "quit", _} ->
            {:quit, local}

          {:command, cmd, args} ->
            case Arvo.TUI.slash(cmd, args) do
              {:ok, :quit, _} ->
                {:quit, local}

              {:ok, :tree, _msg} ->
                # Tree mode lives on TUI state; no system spam on open
                {:cont, %{local | input: "", palette: nil}}

              {:ok, _, msg} when is_binary(msg) ->
                _ = Arvo.TUI.append_system(msg)
                {:cont, %{local | input: "", palette: nil}}

              _ ->
                {:cont, %{local | input: "", palette: nil}}
            end

          _ ->
            {:cont, %{local | input: "", palette: nil}}
        end

      true ->
        case Arvo.TUI.try_begin_turn() do
          :ok ->
            _ = spawn_chat(text)
            {:cont, %{local | input: "", palette: nil}}

          {:error, :busy} ->
            _ = Arvo.Session.steer(text)
            {:cont, %{local | input: "", palette: nil}}
        end
    end
  end

  defp selected_palette_cmd(local) do
    case local[:palette] do
      %{query: q, selected: sel} ->
        items = Arvo.TUI.SlashMenu.filter(q)

        case Enum.at(items, sel) do
          {name, _} -> name
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp spawn_chat(text) do
    # Fire-and-forget product turn on Session (Focus stays responsive for Esc)
    Task.start(fn ->
      ensure_session()

      case Arvo.Session.record_message(%{role: "user", content: text}) do
        {:ok, _} ->
          _ = Arvo.TUI.append_user(text)
          context = Arvo.TurnContext.build()
          model = Arvo.TUI.model()

          event_fun = fn event ->
            Arvo.TUI.handle_event(event)
          end

          case Arvo.Session.start_turn(context, %{model: model}, event_fun) do
            {:ok, _} ->
              _ = Arvo.Session.await_turn()
              :ok

            {:error, :turn_in_progress} ->
              # Should be rare after try_begin_turn; release UI claim
              _ = Arvo.TUI.reset_idle()
              _ = Arvo.TUI.append_system("turn already in progress")
              :ok

            {:error, reason} ->
              _ = Arvo.TUI.reset_idle()
              _ = Arvo.TUI.append_system("turn failed: #{inspect(reason)}")
              :ok
          end

        {:error, reason} ->
          _ = Arvo.TUI.reset_idle()
          _ = Arvo.TUI.append_system("could not record message: #{inspect(reason)}")
          :ok
      end
    end)
  end

  defp ensure_session do
    case Arvo.Session.get() do
      %{path: path} when is_binary(path) ->
        :ok

      _ ->
        cwd = Application.get_env(:arvo, :cwd) || Arvo.cwd()
        _ = Arvo.Session.open_new(cwd)
        :ok
    end
  end

  # Line-mode fallback (non-TTY, tests, CI)
  defp run_line(device) do
    cwd = Application.get_env(:arvo, :cwd) || Arvo.cwd()
    IO.puts(device, "arvo focus (line mode) — cwd=#{cwd}")
    IO.puts(device, Render.footer_line(%{status: :idle}))
    line_loop(device)
  end

  defp line_loop(device) do
    st = Arvo.TUI.state()
    IO.puts(device, Render.ghost_line(st))

    case IO.gets(device, "› ") do
      :eof ->
        IO.puts(device, "bye")
        :ok

      {:error, _} ->
        :ok

      line when is_binary(line) ->
        text = String.trim(line)

        case text do
          t when t in ["quit", "exit", "/quit"] ->
            IO.puts(device, "bye")
            :ok

          "" ->
            line_loop(device)

          "/" <> _ = slash_line ->
            case Arvo.TUI.Commands.parse(slash_line) do
              {:command, "quit", _} ->
                IO.puts(device, "bye")
                :ok

              {:command, cmd, args} ->
                case Arvo.TUI.slash(cmd, args) do
                  {:ok, :quit, msg} ->
                    IO.puts(device, msg)
                    :ok

                  {:ok, _, msg} when is_binary(msg) ->
                    IO.puts(device, msg)
                    line_loop(device)

                  other ->
                    IO.puts(device, inspect(other))
                    line_loop(device)
                end

              _ ->
                line_loop(device)
            end

          chat ->
            run_line_chat(device, chat)
            line_loop(device)
        end
    end
  end

  defp run_line_chat(device, text) do
    ensure_session()
    _ = Arvo.TUI.append_user(text)
    _ = Arvo.Session.record_message(%{role: "user", content: text})
    context = Arvo.TurnContext.build()
    model = Arvo.TUI.model()

    event_fun = fn event ->
      _ = Arvo.TUI.handle_event(event)

      case event do
        {:message_delta, %{text: t}} when is_binary(t) -> IO.write(device, t)
        {:tool_call_start, %{name: n}} -> IO.puts(device, "\n[tool #{n}]")
        {:agent_error, %{error: e}} -> IO.puts(device, "\nerror: #{inspect(e)}")
        _ -> :ok
      end
    end

    case Arvo.Session.start_turn(context, %{model: model}, event_fun) do
      {:ok, _} ->
        case Arvo.Session.await_turn() do
          {:ok, _} -> IO.puts(device, "")
          {:error, :cancelled} -> IO.puts(device, "\n(cancelled)")
          {:error, r} -> IO.puts(device, "error: #{inspect(r)}")
          other -> IO.puts(device, inspect(other))
        end

      {:error, :turn_in_progress} ->
        IO.puts(device, "error: turn already in progress")
    end
  end
end
