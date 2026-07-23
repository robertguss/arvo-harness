defmodule Arvo.Session do
  @moduledoc """
  Current session GenServer: history, steering queue, supervised turn Tasks,
  JSONL persistence + token accounting (SPEC §9).
  """
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  @doc "Start a new persisted session for cwd."
  def open_new(cwd \\ nil, opts \\ []) do
    GenServer.call(__MODULE__, {:open_new, cwd || Application.get_env(:arvo, :cwd) || Arvo.cwd(), opts})
  end

  @doc "Resume the newest session for cwd from tip (or given path)."
  def resume(path_or_cwd \\ nil) do
    GenServer.call(__MODULE__, {:resume, path_or_cwd})
  end

  @doc "Append a message entry to the open session file."
  def record_message(attrs) when is_map(attrs) do
    GenServer.call(__MODULE__, {:record_message, attrs})
  end

  @doc "Record usage tokens for a turn."
  def record_usage(usage) when is_map(usage) do
    GenServer.call(__MODULE__, {:record_usage, usage})
  end

  def tokens do
    GenServer.call(__MODULE__, :tokens)
  end

  @doc """
  Run auto-compaction when cumulative tokens exceed window − 16k reserve (SPEC §10).
  No-op when below threshold or no open session.
  """
  def maybe_auto_compact(opts \\ []) do
    GenServer.call(__MODULE__, {:maybe_auto_compact, opts})
  end

  @doc "Queue steering text while a turn is running."
  def steer(text) when is_binary(text) do
    GenServer.call(__MODULE__, {:steer, text})
  end

  def take_steering do
    GenServer.call(__MODULE__, :take_steering)
  end

  @doc "Start agent turn as a supervised Task. Returns task pid/ref."
  def start_turn(context, config, event_fun) when is_function(event_fun, 1) do
    GenServer.call(__MODULE__, {:start_turn, context, config, event_fun})
  end

  @doc "Cancel current turn Task (brutal kill)."
  def cancel_turn do
    GenServer.call(__MODULE__, :cancel_turn)
  end

  def await_turn(timeout \\ 60_000) do
    GenServer.call(__MODULE__, :await_turn, timeout + 1_000)
  end

  @impl true
  def init(_opts) do
    {:ok,
     %{
       id: nil,
       path: nil,
       last_id: nil,
       history: [],
       cwd: Application.get_env(:arvo, :cwd),
       steering: [],
       turn_task: nil,
       turn_result: nil,
       tokens: Arvo.Session.Tokens.new()
     }}
  end

  @impl true
  def handle_call(:get, _from, state), do: {:reply, state, state}

  def handle_call(:tokens, _from, state), do: {:reply, state.tokens, state}

  def handle_call({:open_new, cwd, opts}, _from, state) do
    {:ok, path, meta} = Arvo.Session.Store.create(cwd, opts)

    state = %{
      state
      | id: meta["id"],
        path: path,
        last_id: meta["id"],
        cwd: cwd,
        history: [meta],
        tokens: Arvo.Session.Tokens.new()
    }

    {:reply, {:ok, path}, state}
  end

  def handle_call({:resume, path_or_cwd}, _from, state) do
    path =
      cond do
        is_binary(path_or_cwd) and String.ends_with?(path_or_cwd, ".jsonl") ->
          path_or_cwd

        is_binary(path_or_cwd) ->
          Arvo.Session.Store.list_for_cwd(path_or_cwd) |> List.first()

        true ->
          Arvo.Session.Store.list_for_cwd(state.cwd || Arvo.cwd()) |> List.first()
      end

    if is_nil(path) do
      {:reply, {:error, :no_session}, state}
    else
      entries = Arvo.Session.Store.read_all(path)
      tip = List.last(entries)
      meta = List.first(entries)

      state = %{
        state
        | id: meta && meta["id"],
          path: path,
          last_id: tip && tip["id"],
          cwd: (meta && meta["cwd"]) || state.cwd,
          history: entries
      }

      messages = Arvo.Session.Store.messages_to_tip(path)
      {:reply, {:ok, %{path: path, messages: messages, tip: tip}}, state}
    end
  end

  def handle_call({:record_message, attrs}, _from, state) do
    if is_nil(state.path) do
      {:reply, {:error, :no_session}, state}
    else
      entry =
        attrs
        |> Map.put("type", Map.get(attrs, "type") || Map.get(attrs, :type) || "message")
        |> Map.put("parent_id", Map.get(attrs, "parent_id") || Map.get(attrs, :parent_id) || state.last_id)

      written = Arvo.Session.Store.append!(state.path, entry)

      state = %{
        state
        | last_id: written["id"],
          history: state.history ++ [written]
      }

      {:reply, {:ok, written}, state}
    end
  end

  def handle_call({:record_usage, usage}, _from, state) do
    tokens = Arvo.Session.Tokens.add(state.tokens, usage)
    state = %{state | tokens: tokens}
    state = do_maybe_auto_compact(state, [])
    {:reply, {:ok, state.tokens}, state}
  end

  def handle_call({:maybe_auto_compact, opts}, _from, state) do
    state2 = do_maybe_auto_compact(state, opts)
    compacted? = state2 != state
    {:reply, if(compacted?, do: {:ok, :compacted}, else: {:ok, :noop}), state2}
  end

  def handle_call({:steer, text}, _from, state) do
    {:reply, :ok, %{state | steering: state.steering ++ [text]}}
  end

  def handle_call(:take_steering, _from, state) do
    {:reply, state.steering, %{state | steering: []}}
  end

  def handle_call({:start_turn, context, config, event_fun}, _from, state) do
    if state.turn_task && Process.alive?(state.turn_task.pid) do
      {:reply, {:error, :turn_in_progress}, state}
    else
      steering = state.steering
      context = Map.put(context, :steering, Map.get(context, :steering, []) ++ steering)
      parent = self()

      task =
        Task.async(fn ->
          result = Arvo.Agent.run(context, config, event_fun)
          send(parent, {:turn_done, result})
          result
        end)

      {:reply, {:ok, task}, %{state | turn_task: task, turn_result: nil, steering: []}}
    end
  end

  def handle_call(:cancel_turn, _from, state) do
    case state.turn_task do
      %Task{pid: pid} = task ->
        Task.shutdown(task, :brutal_kill)
        if Process.alive?(pid), do: Process.exit(pid, :kill)
        {:reply, :ok, %{state | turn_task: nil, turn_result: {:error, :cancelled}}}

      _ ->
        {:reply, :ok, state}
    end
  end

  def handle_call(:await_turn, from, state) do
    case state.turn_result do
      nil ->
        {:noreply, Map.put(state, :await_from, from)}

      result ->
        {:reply, result, %{state | turn_result: nil, turn_task: nil}}
    end
  end

  @impl true
  def handle_info({:turn_done, result}, state) do
    state = %{state | turn_result: result, turn_task: nil}

    case Map.get(state, :await_from) do
      nil ->
        {:noreply, state}

      from ->
        GenServer.reply(from, result)
        {:noreply, Map.delete(%{state | turn_result: nil}, :await_from)}
    end
  end

  def handle_info({ref, _result}, state) when is_reference(ref), do: {:noreply, state}
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state), do: {:noreply, state}
  def handle_info(_msg, state), do: {:noreply, state}

  defp do_maybe_auto_compact(state, opts) do
    window = Keyword.get(opts, :window, 500_000)
    cum = state.tokens.cumulative_total

    if is_binary(state.path) and Arvo.Session.Compaction.should_auto_compact?(cum, window) do
      messages =
        Enum.flat_map(state.history || [], fn e ->
          if e["type"] == "message" do
            [%{role: e["role"], content: e["content"], id: e["id"]}]
          else
            []
          end
        end)

      result =
        Arvo.Session.Compaction.compact(messages, state.history || [],
          instructions: "auto-compact: free context for continued work"
        )

      entry =
        result.entry
        |> Map.put("parent_id", state.last_id)
        |> Map.put("role", "system")

      written = Arvo.Session.Store.append!(state.path, entry)

      %{
        state
        | last_id: written["id"],
          history: state.history ++ [written]
      }
    else
      state
    end
  end
end

