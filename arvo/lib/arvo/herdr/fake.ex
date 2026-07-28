defmodule Arvo.Herdr.Fake do
  @moduledoc """
  In-process fake Herdr adapter for tests.

  Start with `Arvo.Herdr.Fake.start_link/1` (or use Application env
  `:herdr_adapter` → this module after `start_link`). Scriptable via
  `configure/1` and `script/1`.
  """

  @behaviour Arvo.Herdr.Adapter

  use GenServer

  @name __MODULE__

  # --- public test API ---

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, @name)

    case GenServer.start_link(__MODULE__, opts, name: name) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        _ = GenServer.call(pid, :reset)
        {:ok, pid}
    end
  end

  def stop(name \\ @name) do
    case Process.whereis(name) do
      nil ->
        :ok

      pid ->
        try do
          GenServer.stop(pid, :normal)
        catch
          :exit, _ -> :ok
        end
    end
  end

  def reset(name \\ @name) do
    GenServer.call(name, :reset)
  end

  @doc """
  Configure fake behavior.

  Options:
  - `:available` — boolean (default true)
  - `:close_delay_ms` — artificial close latency
  - `:close_error` — if set, close returns `{:error, msg}` once or always
  - `:process_alive` — map pane_id => boolean for process_info
  - `:wait_outputs` — map pane_id => text to return from wait_output
  - `:read_outputs` — map pane_id => text
  """
  def configure(opts, name \\ @name) when is_list(opts) do
    GenServer.call(name, {:configure, opts})
  end

  def panes(name \\ @name), do: GenServer.call(name, :panes)

  def calls(name \\ @name), do: GenServer.call(name, :calls)

  def set_process_alive(pane_id, alive?, name \\ @name) when is_binary(pane_id) do
    GenServer.call(name, {:set_process_alive, pane_id, alive?})
  end

  # --- behaviour ---

  @impl true
  def available?, do: GenServer.call(@name, :available?)

  @impl true
  def split(opts), do: GenServer.call(@name, {:split, opts})

  @impl true
  def run(pane_id, command), do: GenServer.call(@name, {:run, pane_id, command})

  @impl true
  def read(pane_id, opts), do: GenServer.call(@name, {:read, pane_id, opts})

  @impl true
  def wait_output(pane_id, opts), do: GenServer.call(@name, {:wait_output, pane_id, opts})

  @impl true
  def close(pane_id), do: GenServer.call(@name, {:close, pane_id}, 30_000)

  @impl true
  def process_info(pane_id), do: GenServer.call(@name, {:process_info, pane_id})

  # --- GenServer ---

  @impl true
  def init(opts) do
    {:ok, base_state(opts)}
  end

  @impl true
  def handle_call(:reset, _from, _state) do
    {:reply, :ok, base_state([])}
  end

  def handle_call({:configure, opts}, _from, state) do
    state =
      state
      |> Map.put(:available, Keyword.get(opts, :available, state.available))
      |> Map.put(:close_delay_ms, Keyword.get(opts, :close_delay_ms, state.close_delay_ms))
      |> Map.put(:close_error, Keyword.get(opts, :close_error, state.close_error))
      |> Map.put(:wait_error, Keyword.get(opts, :wait_error, state.wait_error))
      |> Map.put(
        :process_alive,
        Map.merge(state.process_alive, Keyword.get(opts, :process_alive, %{}))
      )
      |> Map.put(
        :wait_outputs,
        Map.merge(state.wait_outputs, Keyword.get(opts, :wait_outputs, %{}))
      )
      |> Map.put(
        :read_outputs,
        Map.merge(state.read_outputs, Keyword.get(opts, :read_outputs, %{}))
      )

    {:reply, :ok, state}
  end

  def handle_call(:panes, _from, state), do: {:reply, state.panes, state}
  def handle_call(:calls, _from, state), do: {:reply, Enum.reverse(state.calls), state}
  def handle_call(:available?, _from, state), do: {:reply, state.available, state}

  def handle_call({:set_process_alive, pane_id, alive?}, _from, state) do
    {:reply, :ok, put_in(state, [:process_alive, pane_id], alive?)}
  end

  def handle_call({:split, opts}, _from, state) do
    id = "fake:p#{state.next_id}"
    pane = %{id: id, command: nil, opts: opts, open: true}

    state = %{
      state
      | next_id: state.next_id + 1,
        panes: Map.put(state.panes, id, pane),
        process_alive: Map.put(state.process_alive, id, true),
        calls: [{:split, opts, id} | state.calls]
    }

    {:reply, {:ok, id}, state}
  end

  def handle_call({:run, pane_id, command}, _from, state) do
    case Map.get(state.panes, pane_id) do
      nil ->
        {:reply, {:error, "pane #{pane_id} not found"},
         %{state | calls: [{:run, pane_id, command, :error} | state.calls]}}

      pane ->
        pane = %{pane | command: command}

        state = %{
          state
          | panes: Map.put(state.panes, pane_id, pane),
            process_alive: Map.put(state.process_alive, pane_id, true),
            calls: [{:run, pane_id, command} | state.calls]
        }

        {:reply, :ok, state}
    end
  end

  def handle_call({:read, pane_id, opts}, _from, state) do
    text =
      Map.get(state.read_outputs, pane_id) ||
        case Map.get(state.panes, pane_id) do
          %{command: cmd} when is_binary(cmd) -> "output for: #{cmd}"
          _ -> ""
        end

    state = %{state | calls: [{:read, pane_id, opts} | state.calls]}
    {:reply, {:ok, text}, state}
  end

  def handle_call({:wait_output, pane_id, opts}, _from, state) do
    text =
      Map.get(state.wait_outputs, pane_id) ||
        Map.get(state.read_outputs, pane_id) ||
        "matched"

    timeout = Keyword.get(opts, :timeout)
    alive? = Map.get(state.process_alive, pane_id, true)
    match = Keyword.get(opts, :match) || Keyword.get(opts, :regex)

    {reply, state} =
      cond do
        is_binary(state.wait_error) ->
          {{:error, state.wait_error}, state}

        is_binary(match) and match != "" ->
          {{:ok, %{matched_line: text, text: text}}, state}

        alive? == false ->
          {{:ok, %{matched_line: nil, text: text, exited: true}}, state}

        is_integer(timeout) and timeout <= 1 ->
          {{:error, "timed out waiting for output match"}, state}

        true ->
          {{:ok, %{matched_line: text, text: text}}, state}
      end

    state = %{state | calls: [{:wait_output, pane_id, opts} | state.calls]}
    {:reply, reply, state}
  end

  def handle_call({:close, pane_id}, _from, state) do
    if state.close_delay_ms > 0, do: Process.sleep(state.close_delay_ms)

    state = %{state | calls: [{:close, pane_id} | state.calls]}

    cond do
      is_binary(state.close_error) ->
        {:reply, {:error, state.close_error}, state}

      not Map.has_key?(state.panes, pane_id) ->
        {:reply, {:error, "pane #{pane_id} not found"}, state}

      true ->
        pane = Map.get(state.panes, pane_id)
        pane = %{pane | open: false}

        state = %{
          state
          | panes: Map.put(state.panes, pane_id, pane),
            process_alive: Map.put(state.process_alive, pane_id, false)
        }

        {:reply, :ok, state}
    end
  end

  def handle_call({:process_info, pane_id}, _from, state) do
    alive? = Map.get(state.process_alive, pane_id, false)
    command = get_in(state.panes, [pane_id, :command])

    foreground =
      if alive? and is_binary(command) do
        [%{"name" => "cmd", "cmdline" => command, "argv" => ["bash", "-c", command]}]
      else
        [%{"name" => "zsh", "cmdline" => "-zsh", "argv" => ["-zsh"]}]
      end

    state = %{state | calls: [{:process_info, pane_id} | state.calls]}

    {:reply,
     {:ok,
      %{
        pane_id: pane_id,
        shell_pid: 1,
        foreground_processes: foreground,
        raw: %{}
      }}, state}
  end

  defp base_state(opts) do
    %{
      available: Keyword.get(opts, :available, true),
      next_id: 1,
      panes: %{},
      process_alive: %{},
      wait_outputs: %{},
      read_outputs: %{},
      close_delay_ms: Keyword.get(opts, :close_delay_ms, 0),
      close_error: Keyword.get(opts, :close_error, nil),
      wait_error: Keyword.get(opts, :wait_error, nil),
      calls: []
    }
  end
end
