defmodule Arvo.Herdr do
  @moduledoc """
  Herdr pane control facade (KTD1/KTD2).

  Production uses `Arvo.Herdr.CLI` (subprocess). Tests inject
  `Application.put_env(:arvo, :herdr_adapter, Fake)`.
  """

  @type pane_id :: String.t()
  @type result :: :ok | {:ok, term()} | {:error, String.t()}

  @doc "Adapter module (Application env `:herdr_adapter`, default CLI)."
  def adapter do
    Application.get_env(:arvo, :herdr_adapter, Arvo.Herdr.CLI)
  end

  @doc "True when Herdr is available for live panes (env + binary)."
  def available? do
    adapter().available?()
  end

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
end
