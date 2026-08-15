defmodule Arvo.Herdr do
  @moduledoc """
  Herdr pane control facade.

  Production uses `Arvo.Herdr.CLI` (subprocess). Tests inject
  `Application.put_env(:arvo, :herdr_adapter, Fake)`.
  """

  @type pane_id :: String.t()
  @type result :: :ok | {:ok, term()} | {:error, String.t()}

  @shell_names MapSet.new(["zsh", "bash", "sh", "fish", "nu", "dash", "ksh", "tcsh", "csh"])
  @available_cache_key {__MODULE__, :available?}

  @doc "Adapter module (Application env `:herdr_adapter`, default CLI)."
  def adapter do
    Application.get_env(:arvo, :herdr_adapter, Arvo.Herdr.CLI)
  end

  @doc """
  True when Herdr is available for live panes (env + binary).

  Positive CLI results are cached for the BEAM lifetime. Negative results are
  not cached so attaching Herdr mid-process can still flip to available.
  """
  def available? do
    case :persistent_term.get(@available_cache_key, :miss) do
      true ->
        true

      :miss ->
        if adapter() == Arvo.Herdr.CLI do
          val = adapter().available?()
          # Only cache success — avoids sticky false after late HERDR_ENV attach.
          if val, do: :persistent_term.put(@available_cache_key, true)
          val
        else
          adapter().available?()
        end

      _ ->
        # Stale non-true cache from older builds — recompute.
        :persistent_term.erase(@available_cache_key)
        available?()
    end
  end

  @doc "Clear cached `available?/0` (tests or after adapter/env change)."
  def clear_available_cache do
    :persistent_term.erase(@available_cache_key)
    :ok
  end

  @doc "Normalize pane mode: `:finite` | `:long_lived`."
  def normalize_mode("long_lived"), do: :long_lived
  def normalize_mode(:long_lived), do: :long_lived
  def normalize_mode(_), do: :finite

  @doc """
  True when process-info shows only shell processes — command finished.

  Empty process lists are **not** treated as exited (mid-spawn can briefly
  report empty). Shared by finite wait and the long_lived reaper.
  """
  def process_exited?(%{foreground_processes: []}), do: false

  def process_exited?(%{foreground_processes: procs}) when is_list(procs) do
    Enum.all?(procs, fn p ->
      name = to_string(p["name"] || p[:name] || "")
      shell_name?(name)
    end)
  end

  def process_exited?(_), do: false

  @doc false
  def shell_name?(name) when is_binary(name) do
    MapSet.member?(@shell_names, String.trim_leading(name, "-"))
  end

  def shell_name?(_), do: false

  @doc """
  Split a sibling pane. Options: `:direction` (`:right` | `:down`), `:cwd`,
  `:no_focus` (default true), `:ratio`.
  Returns `{:ok, pane_id}` or `{:error, message}`.
  """
  def split(opts \\ []) when is_list(opts) do
    adapter().split(opts)
  end

  @doc "Run a shell command string in an existing pane."
  def run(pane_id, command) when is_binary(pane_id) and is_binary(command) do
    adapter().run(pane_id, command)
  end

  @doc "Read pane terminal output. Options: `:lines`, `:source`."
  def read(pane_id, opts \\ []) when is_binary(pane_id) and is_list(opts) do
    adapter().read(pane_id, opts)
  end

  @doc """
  Wait for pane output matching `:match` or `:regex`.
  Options: `:match`, `:regex`, `:timeout` (ms), `:lines`, `:source`.
  """
  def wait_output(pane_id, opts) when is_binary(pane_id) and is_list(opts) do
    adapter().wait_output(pane_id, opts)
  end

  @doc "Close a pane."
  def close(pane_id) when is_binary(pane_id) do
    adapter().close(pane_id)
  end

  @doc "Process info for a pane (foreground processes, shell pid)."
  def process_info(pane_id) when is_binary(pane_id) do
    adapter().process_info(pane_id)
  end

  @doc """
  Format operator-visible teardown summary for transcript/TUI.

  `reason` may be an atom (`:cancel`, `:jump`, `:idle_esc`) or a string label.
  """
  def format_teardown_note(reason, results) when is_list(results) do
    label =
      case reason do
        :idle_esc -> "idle Esc"
        :jump -> "HEAD jump"
        :rewind -> "rewind"
        :cancel -> "cancel"
        other when is_atom(other) -> Atom.to_string(other)
        other -> to_string(other)
      end

    cmds =
      results
      |> Enum.map(fn r ->
        pane_id = Map.get(r, :pane_id) || Map.get(r, "pane_id") || "?"
        command = Map.get(r, :command) || Map.get(r, "command") || ""
        status = Map.get(r, :status) || Map.get(r, "status") || "?"
        cmd = if command == "", do: pane_id, else: command
        "#{cmd} (#{status})"
      end)
      |> Enum.join("; ")

    "[arvo: tore down #{length(results)} pane(s) on #{label}: #{cmds}]"
  end
end
