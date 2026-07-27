defmodule Arvo.Session do
  @moduledoc """
  Current session GenServer: history, steering queue, supervised turn Tasks,
  JSONL persistence + token accounting (SPEC §9).

  Product interactive turns are owned here: `start_turn` → Agent Task →
  Session-owned persist/usage on success → idle. Surfaces only dispatch.
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

  @doc """
  Start agent turn as a supervised Task. Returns `{:ok, task}` or `{:error, :turn_in_progress}`.

  On success the Session persists new assistant/tool rows and records usage.
  Cancel forbids success persist.
  """
  def start_turn(context, config, event_fun) when is_function(event_fun, 1) do
    GenServer.call(__MODULE__, {:start_turn, context, config, event_fun})
  end

  @doc "Cancel current turn Task (brutal kill). No success persist; writes cancel leaf."
  def cancel_turn do
    GenServer.call(__MODULE__, :cancel_turn)
  end

  def await_turn(timeout \\ 60_000) do
    GenServer.call(__MODULE__, :await_turn, timeout + 1_000)
  end

  @doc """
  Move HEAD to an earlier node (append-only `head_move`). Next messages parent from new HEAD.

  Steps: positive integer of parent hops from current HEAD (default 1).
  """
  def rewind(steps \\ 1) when is_integer(steps) and steps >= 1 do
    GenServer.call(__MODULE__, {:rewind, steps})
  end

  @doc "Current HEAD entry id (explicit pointer, not necessarily file tip)."
  def head_id do
    GenServer.call(__MODULE__, :head_id)
  end

  @doc "Rebind open session fields (handoff). Idle-only."
  def rebind(state_fields) when is_map(state_fields) do
    GenServer.call(__MODULE__, {:rebind, state_fields})
  end

  @doc """
  Persist only **new** assistant/tool messages from an agent result.

  `prior_len` is the number of non-system messages supplied to the agent
  (session history). Agent result messages are `[system | prior... | new...]`.
  """
  def persist_agent_result(%{messages: messages}, prior_len)
      when is_list(messages) and is_integer(prior_len) and prior_len >= 0 do
    GenServer.call(__MODULE__, {:persist_agent_result, messages, prior_len})
  end

  def persist_agent_result(_, _), do: 0

  @doc "Record usage from agent result into Session + TUI."
  def maybe_record_usage(%{usage: usage}) when is_map(usage) do
    input =
      usage["prompt_tokens"] || usage[:prompt_tokens] || usage["input_tokens"] ||
        usage[:input_tokens] || 0

    output =
      usage["completion_tokens"] || usage[:completion_tokens] || usage["output_tokens"] ||
        usage[:output_tokens] || 0

    if input + output > 0 do
      case record_usage(%{input_tokens: input, output_tokens: output}) do
        {:ok, tokens} ->
          turn = tokens.turn_input + tokens.turn_output
          _ = Arvo.TUI.put_tokens(turn, tokens.cumulative_total)
          {:ok, tokens}

        other ->
          other
      end
    else
      {:ok, :noop}
    end
  end

  def maybe_record_usage(_), do: {:ok, :noop}

  @impl true
  def init(_opts) do
    Process.flag(:trap_exit, true)

    {:ok,
     %{
       id: nil,
       path: nil,
       last_id: nil,
       history: [],
       cwd: Application.get_env(:arvo, :cwd),
       model: nil,
       profile: nil,
       steering: [],
       turn_task: nil,
       turn_result: nil,
       turn_prior_len: nil,
       turn_generation: 0,
       cancelled_generation: nil,
       tokens: Arvo.Session.Tokens.new()
     }}
  end

  @impl true
  def handle_call(:get, _from, state), do: {:reply, state, state}

  def handle_call(:tokens, _from, state), do: {:reply, state.tokens, state}

  def handle_call({:open_new, cwd, opts}, _from, state) do
    opts =
      opts
      |> Keyword.put_new(
        :model,
        Keyword.get(opts, :model) ||
          Application.get_env(:arvo, :default_model) ||
          get_in(Application.get_env(:arvo, :config) || %{}, [:default_model]) ||
          "xai:grok-4.5"
      )
      |> Keyword.put_new(:profile, Keyword.get(opts, :profile) || profile_name())

    {:ok, path, meta} = Arvo.Session.Store.create(cwd, opts)

    state = %{
      state
      | id: meta["id"],
        path: path,
        last_id: meta["id"],
        cwd: cwd,
        history: [meta],
        model: meta["model"],
        profile: meta["profile"],
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
          Arvo.Session.Store.list_resumable_for_cwd(path_or_cwd) |> List.first()

        true ->
          Arvo.Session.Store.list_resumable_for_cwd(state.cwd || Arvo.cwd()) |> List.first()
      end

    if is_nil(path) do
      {:reply, {:error, :no_session}, state}
    else
      entries = Arvo.Session.Store.read_all(path)
      tip = Arvo.Session.Store.tip(path)
      meta = List.first(entries)
      head = Arvo.Session.Store.resolve_head(entries)
      tokens = tokens_from_history(entries)

      state = %{
        state
        | id: meta && meta["id"],
          path: path,
          last_id: head,
          cwd: (meta && meta["cwd"]) || state.cwd,
          history: entries,
          model: meta && meta["model"],
          profile: meta && meta["profile"],
          tokens: tokens
      }

      # Do not call TUI here — resume is often invoked from TUI.slash (deadlock).
      messages = Arvo.Session.Store.messages_to_head(entries)

      {:reply,
       {:ok,
        %{
          path: path,
          messages: messages,
          tip: tip,
          head_id: head,
          tokens: tokens,
          model: state.model,
          profile: state.profile
        }}, state}
    end
  end

  def handle_call(:head_id, _from, state), do: {:reply, state.last_id, state}

  def handle_call({:rewind, steps}, _from, state) do
    if is_nil(state.path) do
      {:reply, {:error, :no_session}, state}
    else
      by_id = Map.new(state.history, &{&1["id"], &1})
      start = by_id[state.last_id]

      target =
        Enum.reduce_while(1..steps, start, fn _, cur ->
          case cur do
            nil ->
              {:halt, nil}

            %{"parent_id" => nil} ->
              {:halt, cur}

            %{"parent_id" => pid} ->
              case by_id[pid] do
                nil -> {:halt, cur}
                parent -> {:cont, parent}
              end
          end
        end)

      case target do
        %{"id" => new_head} ->
          written =
            Arvo.Session.Store.append_head_move!(state.path, new_head, parent_id: state.last_id)

          state = %{
            state
            | last_id: new_head,
              history: state.history ++ [written]
          }

          {:reply, {:ok, %{head_id: new_head}}, state}

        _ ->
          {:reply, {:error, :cannot_rewind}, state}
      end
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
    state = maybe_append_usage_ledger(state, usage, tokens)
    state = do_maybe_auto_compact(state, [])
    {:reply, {:ok, state.tokens}, state}
  end

  def handle_call({:maybe_auto_compact, opts}, _from, state) do
    state2 = do_maybe_auto_compact(state, opts)
    compacted? = state2 != state
    {:reply, if(compacted?, do: {:ok, :compacted}, else: {:ok, :noop}), state2}
  end

  def handle_call({:steer, text}, _from, state) do
    # Mid-turn steering: inject into running context via Agent drain, and keep queue
    # for start_turn merge. Agent pulls via Session.take_steering between model steps
    # only when context.steering is drained — product path also queues here for next step.
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
      prior_len = Map.get(context, :prior_len) || length(List.wrap(Map.get(context, :messages)))
      gen = state.turn_generation + 1
      parent = self()

      # Safe event_fun: never raise into the turn Task
      safe_event = fn event ->
        try do
          event_fun.(event)
        rescue
          _ -> :ok
        catch
          _, _ -> :ok
        end
      end

      task =
        Task.async(fn ->
          result = Arvo.Agent.run(context, config, safe_event)
          send(parent, {:turn_done, gen, result})
          result
        end)

      {:reply, {:ok, task},
       %{
         state
         | turn_task: task,
           turn_result: nil,
           turn_prior_len: prior_len,
           turn_generation: gen,
           cancelled_generation: nil,
           steering: []
       }}
    end
  end

  def handle_call(:cancel_turn, _from, state) do
    case state.turn_task do
      %Task{pid: pid} = task ->
        Task.shutdown(task, :brutal_kill)
        if Process.alive?(pid), do: Process.exit(pid, :kill)

        # Cancel-as-fork: incomplete leaf so HEAD stays coherent; never claim complete success
        state = append_cancel_leaf(state)

        state = %{
          state
          | turn_task: nil,
            turn_result: {:error, :cancelled},
            cancelled_generation: state.turn_generation,
            turn_prior_len: nil
        }

        state = reply_await(state, {:error, :cancelled})
        {:reply, :ok, state}

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

  def handle_call({:persist_agent_result, messages, prior_len}, _from, state) do
    if is_nil(state.path) do
      {:reply, 0, state}
    else
      {count, state} = do_persist_messages(state, messages, prior_len)
      {:reply, count, state}
    end
  end

  def handle_call({:rebind, fields}, _from, state) do
    if state.turn_task && Process.alive?(state.turn_task.pid) do
      {:reply, {:error, :turn_in_progress}, state}
    else
      state = Map.merge(state, fields)
      {:reply, :ok, state}
    end
  end

  @impl true
  def handle_info({:turn_done, gen, result}, state) do
    cond do
      state.cancelled_generation == gen ->
        # Late result after cancel — do not persist success
        {:noreply, state}

      state.turn_generation != gen ->
        {:noreply, state}

      true ->
        state = apply_turn_result(state, result)
        state = reply_await(state, normalize_await_result(result))
        {:noreply, %{state | turn_task: nil}}
    end
  end

  # Task.async EXIT when trap_exit is true — ignore normal completion (turn_done owns result)
  def handle_info({:EXIT, _pid, :normal}, state), do: {:noreply, state}
  def handle_info({:EXIT, _pid, :shutdown}, state), do: {:noreply, state}

  def handle_info({:EXIT, pid, reason}, state) do
    case state.turn_task do
      %Task{pid: ^pid} ->
        if state.cancelled_generation == state.turn_generation do
          {:noreply, %{state | turn_task: nil}}
        else
          result = {:error, {:exit, reason}}
          state = %{state | turn_result: result, turn_task: nil, turn_prior_len: nil}
          state = reply_await(state, result)
          {:noreply, state}
        end

      _ ->
        {:noreply, state}
    end
  end

  def handle_info({ref, _result}, state) when is_reference(ref), do: {:noreply, state}
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state), do: {:noreply, state}
  def handle_info(_msg, state), do: {:noreply, state}

  defp apply_turn_result(state, {:ok, result}) when is_map(result) do
    prior_len = state.turn_prior_len || 0
    {_, state} = do_persist_messages(state, Map.get(result, :messages) || [], prior_len)
    _ = usage_from_result(result)
    tokens = maybe_add_usage_tokens(state.tokens, result)
    state = %{state | tokens: tokens, turn_result: {:ok, result}, turn_prior_len: nil}
    state = do_maybe_auto_compact(state, [])
    # Mirror TUI tokens when usage present
    if tokens.turn_input + tokens.turn_output > 0 do
      turn = tokens.turn_input + tokens.turn_output
      _ = Arvo.TUI.put_tokens(turn, tokens.cumulative_total)
    end

    state
  end

  defp apply_turn_result(state, {:error, _} = err) do
    %{state | turn_result: err, turn_prior_len: nil}
  end

  defp apply_turn_result(state, other) do
    %{state | turn_result: other, turn_prior_len: nil}
  end

  defp normalize_await_result({:ok, result}), do: {:ok, result}
  defp normalize_await_result({:error, _} = err), do: err
  defp normalize_await_result(other), do: other

  defp reply_await(state, result) do
    case Map.get(state, :await_from) do
      nil ->
        %{state | turn_result: result}

      from ->
        GenServer.reply(from, result)
        state |> Map.delete(:await_from) |> Map.put(:turn_result, nil)
    end
  end

  defp do_persist_messages(state, messages, prior_len) when is_list(messages) do
    new_msgs = Enum.drop(messages, prior_len + 1)

    Enum.reduce(new_msgs, {0, state}, fn m, {n, st} ->
      role = m[:role] || m["role"]

      if role in ["assistant", "tool"] do
        entry = message_to_attrs(m)
        entry = Map.put(entry, "parent_id", st.last_id)
        written = Arvo.Session.Store.append!(st.path, entry)
        st = %{st | last_id: written["id"], history: st.history ++ [written]}
        {n + 1, st}
      else
        {n, st}
      end
    end)
  end

  defp do_persist_messages(state, _, _), do: {0, state}

  defp message_to_attrs(m) do
    role = m[:role] || m["role"]
    content = m[:content] || m["content"] || ""

    attrs = %{
      "type" => "message",
      "role" => role,
      "content" => content
    }

    attrs =
      case m[:tool_call_id] || m["tool_call_id"] do
        nil ->
          attrs

        id ->
          Map.merge(attrs, %{
            "tool_call_id" => id,
            "name" => m[:name] || m["name"],
            "is_error" => m[:is_error] || m["is_error"] || false
          })
      end

    case m[:tool_calls] || m["tool_calls"] do
      nil -> attrs
      [] -> attrs
      tcs -> Map.put(attrs, "tool_calls", tcs)
    end
  end

  defp usage_from_result(%{usage: usage}) when is_map(usage), do: usage
  defp usage_from_result(_), do: %{}

  defp maybe_add_usage_tokens(tokens, %{usage: usage}) when is_map(usage) do
    input =
      usage["prompt_tokens"] || usage[:prompt_tokens] || usage["input_tokens"] ||
        usage[:input_tokens] || 0

    output =
      usage["completion_tokens"] || usage[:completion_tokens] || usage["output_tokens"] ||
        usage[:output_tokens] || 0

    if input + output > 0 do
      Arvo.Session.Tokens.add(tokens, %{input_tokens: input, output_tokens: output})
    else
      tokens
    end
  end

  defp maybe_add_usage_tokens(tokens, _), do: tokens

  defp profile_name do
    # Avoid GenServer.call into TUI while holding Session (deadlock risk).
    Application.get_env(:arvo, :active_profile) || "base"
  end

  defp maybe_append_usage_ledger(state, usage, tokens) do
    if is_binary(state.path) do
      input =
        usage[:input_tokens] || usage["input_tokens"] || usage[:prompt_tokens] ||
          usage["prompt_tokens"] || 0

      output =
        usage[:output_tokens] || usage["output_tokens"] || usage[:completion_tokens] ||
          usage["completion_tokens"] || 0

      entry = %{
        "type" => "usage",
        "parent_id" => state.last_id,
        "input_tokens" => input,
        "output_tokens" => output,
        "cumulative_total" => tokens.cumulative_total
      }

      written = Arvo.Session.Store.append!(state.path, entry)
      %{state | history: state.history ++ [written]}
    else
      state
    end
  end

  defp tokens_from_history(entries) when is_list(entries) do
    Enum.reduce(entries, Arvo.Session.Tokens.new(), fn
      %{"type" => "usage"} = e, acc ->
        Arvo.Session.Tokens.add(acc, %{
          input_tokens: e["input_tokens"] || 0,
          output_tokens: e["output_tokens"] || 0
        })

      _, acc ->
        acc
    end)
  end

  defp append_cancel_leaf(state) do
    if is_binary(state.path) and File.exists?(state.path) do
      entry = %{
        "type" => "message",
        "role" => "assistant",
        "content" => "",
        "parent_id" => state.last_id,
        "incomplete" => true,
        "stop_reason" => "cancelled"
      }

      try do
        written = Arvo.Session.Store.append!(state.path, entry)

        %{
          state
          | last_id: written["id"],
            history: state.history ++ [written]
        }
      rescue
        _ -> state
      end
    else
      state
    end
  end

  defp do_maybe_auto_compact(state, opts) do
    # R15: no silent auto-compact on product path unless explicitly opted in
    enabled? =
      Keyword.get(opts, :force, false) or
        Application.get_env(:arvo, :auto_compact, false)

    window = Keyword.get(opts, :window, 500_000)
    cum = state.tokens.cumulative_total

    if enabled? and is_binary(state.path) and
         Arvo.Session.Compaction.should_auto_compact?(cum, window) do
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
