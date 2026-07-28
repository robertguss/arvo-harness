defmodule Arvo.Session do
  @moduledoc """
  Current session GenServer: history, steering queue, supervised turn Tasks,
  JSONL persistence + token accounting (SPEC §9).

  Product interactive turns are owned here: `start_turn` → Agent Task →
  Session-owned persist/usage on success → idle. Surfaces only dispatch.
  """
  use GenServer

  require Logger

  # Long enough for multi-tool loops; HTTP receive_timeout is 120s per complete call.
  @default_await_timeout :infinity

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  @doc "True when a product turn Task is currently running."
  def turn_in_progress? do
    GenServer.call(__MODULE__, :turn_in_progress?)
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

  def await_turn(timeout \\ @default_await_timeout) do
    call_timeout =
      case timeout do
        :infinity -> :infinity
        n when is_integer(n) and n >= 0 -> n + 1_000
      end

    GenServer.call(__MODULE__, :await_turn, call_timeout)
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
  Atomic handoff under the Session lock: idle check, create child, seed packet,
  parent marker, rebind. Prevents start_turn interleaving (TOCTOU).
  """
  def handoff(opts \\ []) when is_list(opts) do
    GenServer.call(__MODULE__, {:handoff, opts}, 60_000)
  end

  @doc """
  Project a tool result under progressive attention (cold + policy + warm + audit).

  Called from Agent mid-turn via context.project_tool_result. Returns a map with
  `:content` (model-facing), `:full_text`, `:cold_id`, `:action`.
  """
  def project_tool_result(tool, args, text, is_error, meta \\ %{}) do
    GenServer.call(
      __MODULE__,
      {:project_tool_result, tool, args, text, is_error, meta || %{}},
      30_000
    )
  end

  @doc "Current live warm work-delta map."
  def warm do
    GenServer.call(__MODULE__, :warm)
  end

  @doc "Set or clear goal from a product-valid writer (user line, pin, opts)."
  def set_warm_goal(goal) do
    GenServer.call(__MODULE__, {:set_warm_goal, goal})
  end

  @doc "Expand a cold entry into a bounded hot slice. Actor: :user | :model | :policy."
  def recall(cold_id, opts \\ []) when is_binary(cold_id) do
    GenServer.call(__MODULE__, {:recall, cold_id, opts})
  end

  @doc "Inspect snapshot: warm fields, cold entry list, audit metrics."
  def inspect_attention do
    GenServer.call(__MODULE__, :inspect_attention)
  end

  @doc "Fetch full cold body by id for the open session (inspect, uncapped)."
  def inspect_cold(cold_id) when is_binary(cold_id) do
    GenServer.call(__MODULE__, {:inspect_cold, cold_id})
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
    %{input_tokens: input, output_tokens: output} = Arvo.Session.Tokens.input_output(usage)

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
     }
     |> put_attention_defaults()}
  end

  @impl true
  def handle_call(:get, _from, state), do: {:reply, state, state}

  def handle_call(:tokens, _from, state), do: {:reply, state.tokens, state}

  def handle_call(:turn_in_progress?, _from, state) do
    {:reply, turn_busy?(state), state}
  end

  def handle_call({:open_new, cwd, opts}, _from, state) do
    if turn_busy?(state) do
      {:reply, {:error, :turn_in_progress}, state}
    else
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
      |> put_attention_defaults()

      {:reply, {:ok, path}, state}
    end
  end

  def handle_call({:resume, path_or_cwd}, _from, state) do
    if turn_busy?(state) do
      {:reply, {:error, :turn_in_progress}, state}
    else
      path =
        cond do
          is_binary(path_or_cwd) and String.ends_with?(path_or_cwd, ".jsonl") ->
            confine_session_path(path_or_cwd)

          is_binary(path_or_cwd) ->
            Arvo.Session.Store.list_resumable_for_cwd(path_or_cwd) |> List.first()

          true ->
            Arvo.Session.Store.list_resumable_for_cwd(state.cwd || Arvo.cwd()) |> List.first()
        end

      cond do
        path == :outside_sessions_root ->
          {:reply, {:error, :path_outside_sessions_root}, state}

        is_nil(path) ->
          {:reply, {:error, :no_session}, state}

        true ->
          entries = Arvo.Session.Store.read_all(path)
          tip = Arvo.Session.Store.tip(entries)
          meta = List.first(entries)
          head = Arvo.Session.Store.resolve_head(entries)
          tokens = tokens_from_history(entries)

          # Rehydrate warm: handoff packet first, else rebuild from HEAD tools (R9)
          warm = warm_from_history(entries)
          path_index = rebuild_path_index(path)

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
          |> put_attention_defaults(warm)
          |> Map.put(:attention_path_index, path_index)

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
  end

  def handle_call(:head_id, _from, state), do: {:reply, state.last_id, state}

  def handle_call({:rewind, steps}, _from, state) do
    cond do
      turn_busy?(state) ->
        {:reply, {:error, :turn_in_progress}, state}

      is_nil(state.path) ->
        {:reply, {:error, :no_session}, state}

      true ->
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

            history = state.history ++ [written]
            # Rebuild warm/attention from new HEAD chain (do not keep abandoned tip state)
            warm = warm_from_history(history)

            state =
              %{
                state
                | last_id: new_head,
                  history: history
              }
              |> put_attention_defaults(warm)
              |> Map.put(:attention_path_index, rebuild_path_index(state.path))

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

      # Product-valid goal writer: first substantial user task line (R5/R9)
      # Skip acks, handoff packets, warm/expand injects so short replies don't invent goals.
      state =
        if (written["role"] || written[:role]) == "user" and
             (written["type"] || "message") == "message" do
          content = to_string(written["content"] || "")

          if product_valid_goal_line?(content) do
            warm = state.warm || Arvo.Session.Warm.empty()
            # Only set if no known goal yet (first task wins); pin/set_warm_goal overrides
            if warm["goal_known"] do
              state
            else
              %{state | warm: Arvo.Session.Warm.set_goal(warm, content)}
            end
          else
            state
          end
        else
          state
        end

      {:reply, {:ok, written}, state}
    end
  end

  def handle_call(:warm, _from, state), do: {:reply, state.warm || Arvo.Session.Warm.empty(), state}

  def handle_call({:set_warm_goal, goal}, _from, state) do
    warm = Arvo.Session.Warm.set_goal(state.warm || Arvo.Session.Warm.empty(), goal)
    {:reply, {:ok, warm}, %{state | warm: warm}}
  end

  def handle_call({:project_tool_result, tool, args, text, is_error, meta}, _from, state) do
    if is_nil(state.path) do
      {:reply,
       %{
         content: text,
         full_text: text,
         action: :full_hot,
         cold_id: nil,
         decision: %{action: :full_hot, reason: :no_session},
         retention: state.attention_retention || %{},
         budgets: state.attention_budgets || Arvo.Attention.default_budgets()
       }, state}
    else
      retention = state.attention_retention || %{}
      # Fidelity TTL uses product-turn clock (bumped in start_turn), not per-tool
      turn = Map.get(retention, :current_turn) || state.attention_product_turn || 0

      result =
        Arvo.Attention.project_tool_result(tool, args, text, is_error, %{
          session_path: state.path,
          retention: retention,
          budgets: state.attention_budgets || Arvo.Attention.default_budgets(),
          current_turn: turn,
          path_index: state.attention_path_index || %{},
          tool_call_id: Map.get(meta, :tool_call_id) || Map.get(meta, "tool_call_id")
        })

      prev_warm = state.warm || Arvo.Session.Warm.empty()

      warm =
        Arvo.Session.Warm.update_from_tool(prev_warm, %{
          tool: tool,
          args: args,
          is_error: is_error,
          text: if(is_error, do: String.slice(to_string(text), 0, 300), else: nil),
          path: result.decision[:path]
        })

      if warm != prev_warm do
        case Arvo.Session.Audit.append(state.path, :warm_update, %{
               "paths" => warm["paths"],
               "goal_known" => warm["goal_known"]
             }) do
          {:ok, _} ->
            :ok

          {:error, reason} ->
            Logger.warning("Arvo.Session warm_update audit failed: #{inspect(reason)}")
        end
      end

      state = %{
        state
        | warm: warm,
          attention_retention: result.retention,
          attention_budgets: result.budgets,
          attention_path_index: result.path_index
      }

      # Agent only needs the projected surface; retention/budgets stay in Session state
      reply = Map.take(result, [:content, :full_text, :action, :cold_id, :decision])
      {:reply, reply, state}
    end
  end

  def handle_call({:recall, cold_id, opts}, _from, state) do
    if is_nil(state.path) do
      {:reply, {:error, :no_session}, state}
    else
      {:reply, Arvo.Attention.expand(state.path, cold_id, opts), state}
    end
  end

  def handle_call(:inspect_attention, _from, state) do
    cold =
      if is_binary(state.path) do
        Arvo.Session.Cold.list(state.path)
      else
        []
      end

    metrics =
      if is_binary(state.path) do
        Arvo.Session.Audit.metrics(state.path)
      else
        Arvo.Session.Audit.empty_metrics()
      end

    {:reply,
     %{
       warm: state.warm || Arvo.Session.Warm.empty(),
       cold: cold,
       metrics: metrics,
       progressive_attention: Arvo.Attention.enabled?()
     }, state}
  end

  def handle_call({:inspect_cold, cold_id}, _from, state) do
    if is_nil(state.path) do
      {:reply, {:error, :no_session}, state}
    else
      {:reply, Arvo.Session.Cold.fetch(state.path, cold_id), state}
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

      # Wire progressive attention projection into Agent (product path default-on)
      context =
        if Map.has_key?(context, :project_tool_result) do
          context
        else
          Map.put(context, :project_tool_result, fn tool, args, text, is_error, meta ->
            Arvo.Session.project_tool_result(tool, args, text, is_error, meta)
          end)
        end

      # Bump fidelity product-turn clock once per start_turn (not per tool)
      product_turn = (state.attention_product_turn || 0) + 1
      retention = state.attention_retention || %{}
      retention = Map.put(retention, :current_turn, product_turn)
      state = %{state | attention_product_turn: product_turn, attention_retention: retention}

      prior_len = Map.get(context, :prior_len) || length(List.wrap(Map.get(context, :messages)))
      gen = state.turn_generation + 1
      parent = self()

      # Safe event_fun: never raise into the turn Task; log so UI failures are not silent
      safe_event = fn event ->
        try do
          event_fun.(event)
        rescue
          e ->
            Logger.warning("Arvo.Session event_fun failed (#{inspect(elem_tag(event))}): #{Exception.message(e)}")
            :ok
        catch
          kind, reason ->
            Logger.warning(
              "Arvo.Session event_fun #{kind} (#{inspect(elem_tag(event))}): #{inspect(reason)}"
            )

            :ok
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
        # If the Task already finished, prefer success persist over a cancel leaf.
        # Task.shutdown returns {:ok, reply} when the process completed.
        case Process.alive?(pid) do
          false ->
            # Drain pending {:turn_done, ...} if any; otherwise treat as already settled.
            receive do
              {:turn_done, gen, result} when gen == state.turn_generation ->
                state = apply_turn_result(state, result)
                state = reply_await(state, result)
                {:reply, :ok, %{state | turn_task: nil}}
            after
              0 ->
                # Result may already be in turn_result via a prior turn_done
                state = reply_await(state, state.turn_result || {:error, :cancelled})
                {:reply, :ok, %{state | turn_task: nil, turn_prior_len: nil}}
            end

          true ->
            case Task.shutdown(task, :brutal_kill) do
              {:ok, result} ->
                # Completed during shutdown — keep success, do not cancel-leaf
                state = apply_turn_result(state, result)
                state = reply_await(state, result)
                {:reply, :ok, %{state | turn_task: nil}}

              _ ->
                if Process.alive?(pid), do: Process.exit(pid, :kill)

                # Cancel-as-fork: incomplete leaf so HEAD stays coherent
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
            end
        end

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
    if turn_busy?(state) do
      {:reply, {:error, :turn_in_progress}, state}
    else
      state = Map.merge(state, fields)
      {:reply, :ok, state}
    end
  end

  def handle_call({:handoff, opts}, _from, state) do
    cond do
      is_nil(state.path) ->
        {:reply, {:error, :no_session}, state}

      turn_busy?(state) ->
        {:reply, {:error, :turn_in_progress}, state}

      true ->
        case Arvo.Session.Handoff.do_perform_locked(state, opts) do
          {:ok, %{rebind: fields} = result} ->
            # Allowlisted rebind keys only (no unbounded Map.merge of caller maps)
            state = apply_handoff_rebind(state, fields)
            {:reply, {:ok, Map.delete(result, :rebind)}, state}

          {:error, _} = err ->
            {:reply, err, state}
        end
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
        state = reply_await(state, result)
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
    if is_nil(state.path) do
      %{state | turn_result: {:ok, result}, turn_prior_len: nil}
    else
      prior_len = state.turn_prior_len || 0
      {_, state} = do_persist_messages(state, Map.get(result, :messages) || [], prior_len)
      usage = usage_from_result(result)
      tokens = maybe_add_usage_tokens(state.tokens, usage)
      state = %{state | tokens: tokens, turn_result: {:ok, result}, turn_prior_len: nil}
      state = maybe_append_usage_ledger(state, usage, tokens)
      state = do_maybe_auto_compact(state, [])

      if tokens.turn_input + tokens.turn_output > 0 do
        turn = tokens.turn_input + tokens.turn_output
        _ = Arvo.TUI.put_tokens(turn, tokens.cumulative_total)
      end

      state
    end
  end

  defp apply_turn_result(state, {:error, _} = err) do
    %{state | turn_result: err, turn_prior_len: nil}
  end

  defp apply_turn_result(state, other) do
    %{state | turn_result: other, turn_prior_len: nil}
  end

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
    if is_nil(state.path) do
      {0, state}
    else
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

    attrs =
      case m[:cold_id] || m["cold_id"] do
        nil -> attrs
        cold_id -> Map.put(attrs, "cold_id", cold_id)
      end

    case m[:tool_calls] || m["tool_calls"] do
      nil -> attrs
      [] -> attrs
      tcs -> Map.put(attrs, "tool_calls", tcs)
    end
  end

  defp usage_from_result(%{usage: usage}) when is_map(usage), do: usage
  defp usage_from_result(_), do: %{}

  defp maybe_add_usage_tokens(tokens, usage) when is_map(usage) do
    io = Arvo.Session.Tokens.input_output(usage)

    if io.input_tokens + io.output_tokens > 0 do
      Arvo.Session.Tokens.add(tokens, io)
    else
      tokens
    end
  end

  defp profile_name do
    # Avoid GenServer.call into TUI while holding Session (deadlock risk).
    Application.get_env(:arvo, :active_profile) || "base"
  end

  defp maybe_append_usage_ledger(state, usage, tokens) when is_map(usage) do
    if is_binary(state.path) do
      %{input_tokens: input, output_tokens: output} = Arvo.Session.Tokens.input_output(usage)

      if input + output > 0 do
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
    else
      state
    end
  end

  defp tokens_from_history(entries) when is_list(entries) do
    Enum.reduce(entries, Arvo.Session.Tokens.new(), fn
      %{"type" => "usage"} = e, acc ->
        Arvo.Session.Tokens.add(acc, e)

      _, acc ->
        acc
    end)
  end

  defp append_cancel_leaf(state) do
    if is_binary(state.path) do
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
        e ->
          Logger.warning("Arvo.Session cancel leaf append failed: #{Exception.message(e)}")
          state
      end
    else
      state
    end
  end

  defp turn_busy?(state) do
    match?(%Task{pid: pid} when is_pid(pid), state.turn_task) and
      Process.alive?(state.turn_task.pid)
  end

  defp apply_handoff_rebind(state, fields) when is_map(fields) do
    child_warm =
      Map.get(fields, :warm) ||
        Map.get(fields, "warm") ||
        Arvo.Session.Warm.empty()

    %{
      state
      | id: Map.get(fields, :id, state.id),
        path: Map.get(fields, :path, state.path),
        last_id: Map.get(fields, :last_id, state.last_id),
        history: Map.get(fields, :history, state.history),
        cwd: Map.get(fields, :cwd, state.cwd),
        model: Map.get(fields, :model, state.model),
        profile: Map.get(fields, :profile, state.profile),
        tokens: Map.get(fields, :tokens, Arvo.Session.Tokens.new()),
        steering: [],
        turn_task: nil,
        turn_result: nil,
        turn_prior_len: nil,
        cancelled_generation: nil,
    }
    |> put_attention_defaults(Arvo.Session.Warm.normalize(child_warm))
  end

  defp put_attention_defaults(state, warm \\ nil) do
    Map.merge(state, %{
      warm: warm || Arvo.Session.Warm.empty(),
      attention_retention: %{},
      attention_budgets: Arvo.Attention.default_budgets(),
      attention_path_index: %{},
      attention_product_turn: 0
    })
  end

  defp rebuild_path_index(session_path) when is_binary(session_path) do
    session_path
    |> Arvo.Session.Cold.list()
    |> Enum.reduce(%{}, fn entry, acc ->
      case entry["source_path"] do
        p when is_binary(p) and p != "" -> Map.put(acc, p, entry)
        _ -> acc
      end
    end)
  end

  defp product_valid_goal_line?(content) when is_binary(content) do
    c = String.trim(content)

    cond do
      c == "" -> false
      c =~ "[handoff packet]" -> false
      c =~ "[warm work-delta]" -> false
      c =~ "[expanded cold:" -> false
      # Short acks / confirmations are not task goals
      String.length(c) < 12 -> false
      c =~ ~r/^(ok|yes|no|y|n|thanks|thank you|lgtm|looks good|continue|go)\.?$/i -> false
      true -> true
    end
  end

  defp product_valid_goal_line?(_), do: false

  defp warm_from_history(entries) when is_list(entries) do
    packet_msg =
      entries
      |> Enum.find(fn e ->
        e["handoff_packet"] == true or
          (is_binary(e["content"]) and e["content"] =~ "[handoff packet]")
      end)

    cond do
      is_map(packet_msg) and is_map(packet_msg["warm"]) ->
        Arvo.Session.Warm.from_packet(packet_msg["warm"])

      is_map(packet_msg) ->
        # Prefer structured warm only; blob reparse is best-effort for legacy seeds
        content = packet_msg["content"] || ""
        goal = capture_packet_field(content, "goal")
        paths = capture_packet_paths(content)
        last_error = capture_packet_field(content, "last_error")
        goal_known_raw = capture_packet_field(content, "goal_known")

        goal_known =
          cond do
            goal_known_raw in ["true", "True"] -> true
            true -> false
          end

        Arvo.Session.Warm.from_packet(%{
          "goal" => if(goal_known, do: goal, else: nil),
          "paths" => paths,
          "last_error" => last_error,
          "goal_known" => goal_known
        })

      true ->
        # Non-handoff resume: rebuild paths/errors from HEAD tool messages
        rebuild_warm_from_messages(Arvo.Session.Store.messages_to_head(entries))
    end
  end

  defp rebuild_warm_from_messages(messages) when is_list(messages) do
    warm =
      Enum.reduce(messages, Arvo.Session.Warm.empty(), fn m, w ->
        role = m[:role] || m["role"]
        content = to_string(m[:content] || m["content"] || "")

        cond do
          role == "user" and product_valid_goal_line?(content) and not w["goal_known"] ->
            Arvo.Session.Warm.set_goal(w, content)

          role == "tool" ->
            Arvo.Session.Warm.update_from_tool(w, %{
              tool: m[:name] || m["name"] || "tool",
              args: %{},
              is_error: m[:is_error] || m["is_error"] || false,
              text: if(m[:is_error] || m["is_error"], do: String.slice(content, 0, 300), else: nil),
              path: nil
            })

          true ->
            w
        end
      end)

    # Paths from cold index are better for tool path recovery
    warm
  end

  defp capture_packet_field(content, key) when is_binary(content) do
    case Regex.run(~r/^#{Regex.escape(key)}:\s*(.*)$/m, content) do
      [_, v] -> String.trim(v)
      _ -> nil
    end
  end

  defp capture_packet_paths(content) when is_binary(content) do
    case capture_packet_field(content, "paths") do
      nil ->
        []

      s ->
        case Regex.scan(~r/"([^"]+)"/, s) do
          [] -> []
          matches -> Enum.map(matches, fn [_, p] -> p end)
        end
    end
  end

  defp confine_session_path(path) when is_binary(path) do
    expanded = Path.expand(path)
    root = Path.expand(Arvo.Session.Store.sessions_root())

    if expanded == root or String.starts_with?(expanded, root <> "/") do
      expanded
    else
      :outside_sessions_root
    end
  end

  defp elem_tag(event) when is_tuple(event) and tuple_size(event) > 0, do: elem(event, 0)
  defp elem_tag(other), do: other

  defp do_maybe_auto_compact(state, opts) do
    # R15: silent auto-compact is off unless force: true or :auto_compact env
    enabled? =
      Keyword.get(opts, :force, false) or
        Application.get_env(:arvo, :auto_compact, false)

    window = Keyword.get(opts, :window, 500_000)
    cum = state.tokens.cumulative_total

    if enabled? and is_binary(state.path) and
         Arvo.Session.Compaction.should_auto_compact?(cum, window) do
      messages = Arvo.Session.Store.messages_to_head(state.history || [])

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
