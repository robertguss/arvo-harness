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
    GenServer.call(
      __MODULE__,
      {:open_new, cwd || Application.get_env(:arvo, :cwd) || Arvo.cwd(), opts}
    )
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
    GenServer.call(__MODULE__, :cancel_turn, 30_000)
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
  Thin wrapper over ancestor walk + `jump_to` shared head-move path (legacy; prefer `/tree`).
  """
  def rewind(steps \\ 1) when is_integer(steps) and steps >= 1 do
    GenServer.call(__MODULE__, {:rewind, steps})
  end

  @doc """
  Move HEAD to a specific message entry id (append-only `head_move`).

  Idle-only. Target must be a jumpable user/assistant message in history.
  Returns `{:ok, %{head_id, messages}}` where `messages` is root→HEAD for Focus rehydrate.
  Jump to current HEAD is a no-op (no new head_move).
  """
  def jump_to(entry_id) when is_binary(entry_id) do
    GenServer.call(__MODULE__, {:jump_to, entry_id}, 30_000)
  end

  @doc """
  Register an Arvo-owned Herdr pane for Esc/HEAD teardown (KTD3).

  attrs: `:pane_id` (required), `:mode` (`:finite` | `:long_lived`), `:command`,
  `:turn_id`, `:start_reaper` (default true for long_lived).
  """
  def register_pane(attrs) when is_map(attrs) do
    GenServer.call(__MODULE__, {:register_pane, attrs})
  end

  @doc "Unregister a pane after clean close (no Herdr kill)."
  def unregister_pane(pane_id) when is_binary(pane_id) do
    GenServer.call(__MODULE__, {:unregister_pane, pane_id})
  end

  @doc "List Arvo-owned panes currently registered (for TUI live status)."
  def owned_panes do
    GenServer.call(__MODULE__, :owned_panes)
  end

  @doc """
  Explicitly kill/close all registered Arvo-owned panes with bounded I/O.

  reason: `:cancel` | `:jump` | `:idle_esc` | atom. Returns
  `{:ok, results}` where each result has `:pane_id`, `:command`, `:status`.
  """
  def teardown_owned_panes(reason \\ :cancel) do
    GenServer.call(__MODULE__, {:teardown_owned_panes, reason}, 30_000)
  end

  @doc """
  Start a process-exit reaper for an already-registered long_lived pane (KTD8).

  Prefer calling this after running-state return, not at register time, so early
  shell-only process-info does not close the pane mid-start.
  """
  def ensure_pane_reaper(pane_id) when is_binary(pane_id) do
    GenServer.call(__MODULE__, {:ensure_pane_reaper, pane_id})
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
       tokens: Arvo.Session.Tokens.new(),
       # Arvo-owned Herdr panes (KTD3): pane_id => meta map
       owned_panes: %{}
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
        # Bind treatment from env/config at open (KTD-T1); Store persists into meta
        |> Keyword.put_new(:attention_mode, Arvo.Attention.treatment_mode_from_env())
        |> Keyword.put_new(:policy_version, Arvo.Attention.policy_version())

      {:ok, path, meta} = Arvo.Session.Store.create(cwd, opts)

      {_results, state} = do_teardown_owned_panes(state, :open_new)

      state =
        %{
          state
          | id: meta["id"],
            path: path,
            last_id: meta["id"],
            cwd: cwd,
            history: [meta],
            model: meta["model"],
            profile: meta["profile"],
            tokens: Arvo.Session.Tokens.new(),
            owned_panes: %{}
        }
        |> put_attention_defaults()
        |> put_treatment_from_meta(meta)

      state = emit_session_treatment(state)
      cast_attention_mode(state)

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
          # Abandon Arvo-owned panes from the prior live session before rebind.
          {_teardown, state} = do_teardown_owned_panes(state, :resume)

          entries = Arvo.Session.Store.read_all(path)
          tip = Arvo.Session.Store.tip(entries)
          meta = List.first(entries)
          head = Arvo.Session.Store.resolve_head(entries)
          tokens = tokens_from_history(entries)

          # Rehydrate warm: handoff packet first, else rebuild from HEAD tools (R9)
          warm = warm_from_history(entries)
          path_index = rebuild_path_index(path)

          state =
            %{
              state
              | id: meta && meta["id"],
                path: path,
                last_id: head,
                cwd: (meta && meta["cwd"]) || state.cwd,
                history: entries,
                model: meta && meta["model"],
                profile: meta && meta["profile"],
                tokens: tokens,
                owned_panes: %{}
            }
            |> put_attention_defaults(warm)
            |> Map.put(:attention_path_index, path_index)
            # KTD-T1: metadata wins after open — do not flip treatment from ambient env
            |> put_treatment_from_meta(meta)
            |> restore_audit_sequence(path)

          # Do not GenServer.call TUI here — resume is often invoked from TUI.slash (deadlock).
          # R17: include attention_mode in reply so TUI rehydrate can set ambient enablement.
          # R4: access chrome rebuild from audit on resume is deferred (live-only ship-ready).
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
              profile: state.profile,
              attention_mode: state.attention_mode || "on"
            }}, state}
      end
    end
  end

  def handle_call(:head_id, _from, state), do: {:reply, state.last_id, state}

  def handle_call({:jump_to, entry_id}, _from, state) do
    cond do
      turn_busy?(state) ->
        {:reply, {:error, :turn_in_progress}, state}

      is_nil(state.path) ->
        {:reply, {:error, :no_session}, state}

      true ->
        case Map.new(state.history, &{&1["id"], &1})[entry_id] do
          nil ->
            {:reply, {:error, :unknown_id}, state}

          entry ->
            if Arvo.Session.Store.jumpable_entry?(entry) do
              # No-op jump to current HEAD leaves panes alone; abandon otherwise.
              {teardown_results, state} =
                if state.last_id == entry_id do
                  {[], state}
                else
                  do_teardown_owned_panes(state, :jump)
                end

              case apply_head_move(state, entry_id) do
                {:ok, state, result} ->
                  {:reply, {:ok, Map.put(result, :pane_teardown, teardown_results)}, state}

                {:error, reason} ->
                  {:reply, {:error, reason}, state}
              end
            else
              {:reply, {:error, :not_jumpable}, state}
            end
        end
    end
  end

  def handle_call({:register_pane, attrs}, _from, state) do
    pane_id = attrs[:pane_id] || attrs["pane_id"]

    if not is_binary(pane_id) or pane_id == "" do
      {:reply, {:error, :invalid_pane_id}, state}
    else
      mode = Arvo.Herdr.normalize_mode(attrs[:mode] || attrs["mode"] || :finite)
      command = attrs[:command] || attrs["command"] || ""
      turn_id = attrs[:turn_id] || attrs["turn_id"]
      # Reaper is opt-in (ensure_pane_reaper after running-state) so shell-only
      # process-info mid-start does not close the pane early.
      start_reaper? = attrs[:start_reaper] || attrs["start_reaper"]
      start_reaper? = start_reaper? in [true, "true"]

      reaper =
        if start_reaper? do
          spawn_pane_reaper(pane_id)
        else
          nil
        end

      meta = %{
        pane_id: pane_id,
        mode: mode,
        command: command,
        turn_id: turn_id,
        reaper: reaper,
        registered_at: System.system_time(:millisecond)
      }

      state = put_in(state, [:owned_panes, pane_id], meta)
      notify_pane_chrome(state)
      {:reply, :ok, state}
    end
  end

  def handle_call({:unregister_pane, pane_id}, _from, state) do
    case Map.pop(state.owned_panes, pane_id) do
      {nil, _} ->
        {:reply, :ok, state}

      {meta, panes} ->
        stop_reaper(meta[:reaper])
        state = %{state | owned_panes: panes}
        notify_pane_chrome(state)
        {:reply, :ok, state}
    end
  end

  def handle_call(:owned_panes, _from, state) do
    {:reply, owned_panes_list(state), state}
  end

  def handle_call({:teardown_owned_panes, reason}, _from, state) do
    {results, state} = do_teardown_owned_panes(state, reason)
    {:reply, {:ok, results}, state}
  end

  def handle_call({:ensure_pane_reaper, pane_id}, _from, state) do
    case Map.get(state.owned_panes, pane_id) do
      nil ->
        {:reply, {:error, :unknown_pane}, state}

      %{reaper: pid} = meta when is_pid(pid) ->
        if Process.alive?(pid) do
          {:reply, :ok, state}
        else
          reaper = spawn_pane_reaper(pane_id)
          state = put_in(state, [:owned_panes, pane_id], %{meta | reaper: reaper})
          {:reply, :ok, state}
        end

      meta ->
        reaper = spawn_pane_reaper(pane_id)
        state = put_in(state, [:owned_panes, pane_id], %{meta | reaper: reaper})
        {:reply, :ok, state}
    end
  end

  def handle_call({:rewind, steps}, _from, state) do
    cond do
      turn_busy?(state) ->
        {:reply, {:error, :turn_in_progress}, state}

      is_nil(state.path) ->
        {:reply, {:error, :no_session}, state}

      true ->
        by_id = Map.new(state.history, &{&1["id"], &1})
        start = by_id[state.last_id]
        target = walk_ancestors(start, by_id, steps)

        case target do
          %{"id" => new_head} ->
            {teardown_results, state} =
              if state.last_id != new_head do
                do_teardown_owned_panes(state, :rewind)
              else
                {[], state}
              end

            case apply_head_move(state, new_head) do
              {:ok, state, result} ->
                {:reply, {:ok, Map.put(result, :pane_teardown, teardown_results)}, state}

              {:error, :unknown_id} ->
                {:reply, {:error, :cannot_rewind}, state}
            end

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
        |> Map.put(
          "parent_id",
          Map.get(attrs, "parent_id") || Map.get(attrs, :parent_id) || state.last_id
        )

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

  def handle_call(:warm, _from, state),
    do: {:reply, state.warm || Arvo.Session.Warm.empty(), state}

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
      # RecallEvidence already expanded under caps and audited via Session.recall —
      # never re-stub recovery results (would re-strand the model).
      if recovery_tool?(tool) do
        {:reply,
         %{
           content: text,
           full_text: text,
           action: :full_hot,
           cold_id: nil,
           decision: %{action: :full_hot, reason: :recovery_tool},
           audit_error?: (state.audit_write_errors || 0) > 0
         }, state}
      else
        retention = state.attention_retention || %{}
        # Fidelity TTL uses product-turn clock (bumped in start_turn), not per-tool
        turn = Map.get(retention, :current_turn) || state.attention_product_turn || 0
        tool_call_id = Map.get(meta, :tool_call_id) || Map.get(meta, "tool_call_id")

        result =
          Arvo.Attention.project_tool_result(tool, args, text, is_error, %{
            session_path: state.path,
            retention: retention,
            budgets: state.attention_budgets || Arvo.Attention.default_budgets(),
            current_turn: turn,
            path_index: state.attention_path_index || %{},
            tool_call_id: tool_call_id,
            attention_mode: state.attention_mode || "on",
            turn_id: state.attention_product_turn
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

        events = Map.get(result, :events) || []

        events =
          if warm != prev_warm do
            events ++
              [
                {:warm_update,
                 %{
                   "paths" => warm["paths"],
                   "goal_known" => warm["goal_known"]
                 }}
              ]
          else
            events
          end

        {state, written} =
          commit_audit_events_with_written(state, events, %{
            tool_call_id: tool_call_id,
            turn_id: state.attention_product_turn
          })

        state = %{
          state
          | warm: warm,
            attention_retention: result.retention,
            attention_budgets: result.budgets,
            attention_path_index: result.path_index
        }

        chrome = aggregate_projection_chrome(written, result)

        # Agent only needs the projected surface + chrome join keys for TUI (R13/AE11).
        # Retention/budgets stay in Session state. Access chrome is TUI-local (R11).
        reply =
          result
          |> Map.take([:content, :full_text, :action, :cold_id, :decision])
          |> Map.put(:audit_error?, (state.audit_write_errors || 0) > 0)
          |> Map.put(:event_id, chrome.event_id)
          |> Map.put(:reason_class, chrome.reason_class)
          |> Map.put(:attention_secondary, chrome.secondary)

        {:reply, reply, state}
      end
    end
  end

  def handle_call({:recall, cold_id, opts}, _from, state) do
    if is_nil(state.path) do
      {:reply, {:error, :no_session}, state}
    else
      tool_call_id = Keyword.get(opts, :tool_call_id)
      envelope = %{turn_id: state.attention_product_turn, tool_call_id: tool_call_id}

      case Arvo.Attention.expand(state.path, cold_id, opts) do
        {:ok, out, events} ->
          {state, written} = commit_audit_events_with_written(state, events, envelope)
          cast_expand_access_chrome(written, cold_id, tool_call_id)
          {:reply, {:ok, out}, state}

        {:error, reason, events} ->
          {state, written} = commit_audit_events_with_written(state, events, envelope)
          cast_expand_access_chrome(written, cold_id, tool_call_id)
          {:reply, {:error, reason}, state}
      end
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
       progressive_attention: (state.attention_mode || "on") == "on",
       attention_mode: state.attention_mode || "on",
       policy_version: state.policy_version || Arvo.Attention.policy_version(),
       treatment_assigned_at: state.treatment_assigned_at,
       audit_write_errors: state.audit_write_errors || 0
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
            Logger.warning(
              "Arvo.Session event_fun failed (#{inspect(elem_tag(event))}): #{Exception.message(e)}"
            )

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
    # Always tear down Arvo-owned panes when registry non-empty (R12), even if
    # turn_task is nil (idle long_lived panes after running-state return).
    {_pane_results, state} = do_teardown_owned_panes(state, :cancel)

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

  # --- Arvo-owned pane registry ---

  @pane_close_timeout_ms 2_000
  @pane_reaper_poll_ms 500
  @pane_reaper_poll_max_ms 2_000

  defp do_teardown_owned_panes(state, reason) do
    panes = Map.values(state.owned_panes || %{})

    if panes == [] do
      {[], state}
    else
      # Stop reapers first, then close panes in parallel (bounded per-pane timeout).
      Enum.each(panes, fn meta -> stop_reaper(meta[:reaper]) end)
      adapter = Arvo.Herdr.adapter()

      results =
        panes
        |> Task.async_stream(
          fn meta ->
            pane_id = meta.pane_id
            command = meta[:command] || ""

            status =
              try do
                case adapter.close(pane_id) do
                  :ok ->
                    :closed

                  {:error, msg} ->
                    Logger.warning("Arvo.Session pane close error #{pane_id}: #{msg}")
                    :error
                end
              catch
                :exit, exit_reason ->
                  Logger.warning(
                    "Arvo.Session pane close exit #{pane_id}: #{inspect(exit_reason)}"
                  )

                  :error
              end

            %{pane_id: pane_id, command: command, status: status, reason: reason}
          end,
          timeout: @pane_close_timeout_ms,
          on_timeout: :kill_task,
          max_concurrency: 8,
          ordered: true
        )
        |> Enum.zip(panes)
        |> Enum.map(fn
          {{:ok, result}, _meta} ->
            result

          {{:exit, :timeout}, meta} ->
            Logger.warning("Arvo.Session pane close timeout #{meta.pane_id}")

            %{
              pane_id: meta.pane_id,
              command: meta[:command] || "",
              status: :timeout,
              reason: reason
            }

          {{:exit, exit_reason}, meta} ->
            Logger.warning(
              "Arvo.Session pane close task exit #{meta.pane_id}: #{inspect(exit_reason)}"
            )

            %{
              pane_id: meta.pane_id,
              command: meta[:command] || "",
              status: :error,
              reason: reason
            }
        end)

      note = Arvo.Herdr.format_teardown_note(reason, results)
      state = append_pane_teardown_note(state, note, reason)
      Logger.info(note)
      state = %{state | owned_panes: %{}}
      notify_pane_chrome(state)

      {results, state}
    end
  end

  defp owned_panes_list(state) do
    state.owned_panes
    |> Map.values()
    |> Enum.map(fn m ->
      Map.take(m, [:pane_id, :mode, :command, :turn_id, :registered_at])
    end)
  end

  defp append_pane_teardown_note(state, note, reason) when is_binary(note) do
    if is_binary(state.path) do
      # Durable audit row — not a model message (avoids incomplete assistant pollution).
      entry = %{
        "type" => "pane_teardown",
        "parent_id" => state.last_id,
        "content" => note,
        "reason" => to_string(reason)
      }

      try do
        written = Arvo.Session.Store.append!(state.path, entry)
        # Do not advance HEAD — teardown is audit, not a conversation fork point.
        %{state | history: state.history ++ [written]}
      rescue
        e ->
          Logger.warning("Arvo.Session pane teardown note failed: #{Exception.message(e)}")
          state
      end
    else
      state
    end
  end

  defp spawn_pane_reaper(pane_id) when is_binary(pane_id) do
    parent = self()

    spawn(fn ->
      _ref = Process.monitor(parent)
      pane_reaper_loop(pane_id, parent, @pane_reaper_poll_ms, 0)
    end)
  end

  defp pane_reaper_loop(_pane_id, _session_pid, _poll_ms, attempts) when attempts > 43_200 do
    # ~12h at ~1s average — give up quietly
    :ok
  end

  defp pane_reaper_loop(pane_id, session_pid, poll_ms, attempts) do
    receive do
      {:DOWN, _ref, :process, ^session_pid, _reason} ->
        :ok
    after
      poll_ms ->
        case Arvo.Herdr.process_info(pane_id) do
          {:ok, info} ->
            if Arvo.Herdr.process_exited?(info) do
              _ = Arvo.Herdr.close(pane_id)

              try do
                Arvo.Session.unregister_pane(pane_id)
              catch
                :exit, _ -> :ok
              end
            else
              next_poll = min(poll_ms * 2, @pane_reaper_poll_max_ms)
              pane_reaper_loop(pane_id, session_pid, next_poll, attempts + 1)
            end

          {:error, _} ->
            try do
              Arvo.Session.unregister_pane(pane_id)
            catch
              :exit, _ -> :ok
            end
        end
    end
  end

  defp stop_reaper(nil), do: :ok

  defp stop_reaper(pid) when is_pid(pid) do
    Process.exit(pid, :kill)
    :ok
  end

  defp stop_reaper(_), do: :ok

  # Push pane list into TUI — never GenServer.call TUI (AB-BA with slash/Esc).
  defp notify_pane_chrome(state) do
    case Process.whereis(Arvo.TUI) do
      pid when is_pid(pid) ->
        GenServer.cast(pid, {:set_live_panes, owned_panes_list(state)})

      _ ->
        :ok
    end
  end

  # Shared HEAD rewrite used by jump_to (jumpable gate) and rewind (any ancestor).
  # No-op when already at entry_id: returns messages without appending head_move.
  defp apply_head_move(state, entry_id) when is_binary(entry_id) do
    by_id = Map.new(state.history, &{&1["id"], &1})

    case by_id[entry_id] do
      nil ->
        {:error, :unknown_id}

      _entry ->
        if state.last_id == entry_id do
          msgs = Arvo.Session.Store.messages_to_head(state.history)
          {:ok, state, %{head_id: entry_id, messages: msgs}}
        else
          written =
            Arvo.Session.Store.append_head_move!(state.path, entry_id, parent_id: state.last_id)

          history = state.history ++ [written]
          warm = warm_from_history(history)

          state =
            %{state | last_id: entry_id, history: history}
            |> put_attention_defaults(warm)
            |> Map.put(:attention_path_index, rebuild_path_index(state.path))

          msgs = Arvo.Session.Store.messages_to_head(history)
          {:ok, state, %{head_id: entry_id, messages: msgs}}
        end
    end
  end

  defp walk_ancestors(start, by_id, steps) do
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
        cancelled_generation: nil
    }
    |> put_attention_defaults(Arvo.Session.Warm.normalize(child_warm))
  end

  defp put_attention_defaults(state, warm \\ nil) do
    Map.merge(state, %{
      warm: warm || Arvo.Session.Warm.empty(),
      attention_retention: %{},
      attention_budgets: Arvo.Attention.default_budgets(),
      attention_path_index: %{},
      attention_product_turn: 0,
      attention_mode: Map.get(state, :attention_mode) || "on",
      policy_version: Map.get(state, :policy_version) || Arvo.Attention.policy_version(),
      treatment_assigned_at: Map.get(state, :treatment_assigned_at),
      audit_sequence: Map.get(state, :audit_sequence) || 0,
      audit_write_errors: Map.get(state, :audit_write_errors) || 0
    })
  end

  defp put_treatment_from_meta(state, meta) when is_map(meta) do
    mode =
      case meta["attention_mode"] do
        "off" -> "off"
        :off -> "off"
        _ -> "on"
      end

    %{
      state
      | attention_mode: mode,
        policy_version: meta["policy_version"] || Arvo.Attention.policy_version(),
        treatment_assigned_at: meta["treatment_assigned_at"]
    }
  end

  defp put_treatment_from_meta(state, _), do: state

  defp emit_session_treatment(state) do
    if is_binary(state.path) do
      events = [
        {:session_treatment,
         %{
           "attention_mode" => state.attention_mode || "on",
           "policy_version" => state.policy_version || Arvo.Attention.policy_version(),
           "treatment_assigned_at" =>
             state.treatment_assigned_at || DateTime.utc_now() |> DateTime.to_iso8601()
         }}
      ]

      commit_audit_events(state, events, %{})
    else
      state
    end
  end

  # Ambient enablement for Focus ghost (R17). Cast-only — never call TUI under Session.
  defp cast_attention_mode(state) do
    mode = if (state.attention_mode || "on") == "off", do: "off", else: "on"

    try do
      _ = Arvo.TUI.put_attention_mode(mode)
    rescue
      _ -> :ok
    catch
      :exit, _ -> :ok
    end

    :ok
  end

  # R20 expand/denied chrome from committed audit events (operator display only).
  defp cast_expand_access_chrome(written, cold_id, tool_call_id) when is_list(written) do
    written
    |> Enum.filter(fn e -> e["type"] in ["expand", "denied_expand"] end)
    |> Enum.each(fn e ->
      type = e["type"]
      reason_class = e["reason_class"]

      outcome =
        cond do
          type == "expand" -> :expand
          reason_class in ["cap_exceeded", "capped"] -> :capped
          true -> :denied
        end

      payload = %{
        outcome: outcome,
        type: type,
        cold_id: e["id"] || cold_id,
        reason_class: reason_class,
        event_id: e["event_id"],
        tool_call_id: e["tool_call_id"] || tool_call_id,
        actor: e["actor"]
      }

      try do
        _ = Arvo.TUI.put_access_chrome(payload)
      rescue
        _ -> :ok
      catch
        :exit, _ -> :ok
      end
    end)

    :ok
  end

  defp cast_expand_access_chrome(_, _, _), do: :ok

  # R19: one primary projection outcome + secondary store/reuse flags from audit.
  defp aggregate_projection_chrome(written, result) when is_list(written) do
    types = MapSet.new(Enum.map(written, & &1["type"]))

    primary =
      Enum.find(written, &(&1["type"] == "stub_in_hot")) ||
        Enum.find(written, &(&1["type"] == "full_hot")) ||
        Enum.find(written, &(&1["type"] == "reuse_cold")) ||
        List.last(written)

    secondary =
      []
      |> then(fn s -> if MapSet.member?(types, "store_cold"), do: [:store | s], else: s end)
      |> then(fn s -> if MapSet.member?(types, "reuse_cold"), do: [:reuse | s], else: s end)
      |> Enum.reverse()

    reason_class =
      (primary && primary["reason_class"]) ||
        get_in(result, [:decision, :reason]) ||
        get_in(result, [:decision, "reason"])

    reason_class =
      if reason_class,
        do: Arvo.Session.Audit.normalize_reason_class(reason_class),
        else: nil

    %{
      event_id: primary && primary["event_id"],
      reason_class: reason_class,
      secondary: secondary
    }
  end

  defp aggregate_projection_chrome(_, result) do
    reason =
      get_in(result, [:decision, :reason]) || get_in(result, [:decision, "reason"])

    %{
      event_id: nil,
      reason_class: reason && Arvo.Session.Audit.normalize_reason_class(reason),
      secondary: []
    }
  end

  # Session sole durable writer (KTD-E1). Surfaces failures when treatment=on.
  defp commit_audit_events(state, events, meta) do
    {state, _written} = commit_audit_events_with_written(state, events, meta)
    state
  end

  defp commit_audit_events_with_written(state, [], _meta), do: {state, []}

  defp commit_audit_events_with_written(state, events, meta) when is_list(events) do
    if is_nil(state.path) do
      {state, []}
    else
      envelope = %{
        session_id: state.id,
        sequence: state.audit_sequence || 0,
        attention_mode: state.attention_mode || "on",
        policy_version: state.policy_version || Arvo.Attention.policy_version(),
        turn_id: Map.get(meta, :turn_id) || Map.get(meta, "turn_id"),
        tool_call_id: Map.get(meta, :tool_call_id) || Map.get(meta, "tool_call_id"),
        committed: "committed"
      }

      case Arvo.Session.Audit.append_many(state.path, events, envelope) do
        {:ok, written} ->
          next_seq =
            written
            |> Enum.map(& &1["sequence"])
            |> Enum.reject(&is_nil/1)
            |> Enum.max(fn -> state.audit_sequence || 0 end)

          {%{state | audit_sequence: next_seq}, written}

        {:error, reason} ->
          Logger.error("Arvo.Session audit write failed: #{inspect(reason)}")
          errors = (state.audit_write_errors || 0) + 1
          state = %{state | audit_write_errors: errors}

          # Surface as scorer-visible failure when treatment is on (KTD-E1).
          # Primary path failed — still record in-memory; do not Logger-only.
          state =
            if (state.attention_mode || "on") == "on" do
              try_audit_error_event(state, reason)
            else
              state
            end

          {state, []}
      end
    end
  end

  defp try_audit_error_event(state, reason) do
    # Best-effort secondary write so honesty scorers can see attention_audit_error.
    # Envelope must be committed=committed: scorers/metrics only count committed lines.
    # Payload records that the *primary* write failed (KTD-E1 honesty).
    envelope = %{
      session_id: state.id,
      sequence: state.audit_sequence || 0,
      attention_mode: state.attention_mode || "on",
      policy_version: state.policy_version || Arvo.Attention.policy_version(),
      committed: "committed"
    }

    case Arvo.Session.Audit.append_many(
           state.path,
           [
             {:attention_audit_error,
              %{
                "reason" => inspect(reason),
                "reason_class" => "unknown",
                "primary_write" => "failed",
                "error_count" => state.audit_write_errors || 1
              }}
           ],
           envelope
         ) do
      {:ok, written} ->
        next_seq =
          written
          |> Enum.map(& &1["sequence"])
          |> Enum.reject(&is_nil/1)
          |> Enum.max(fn -> state.audit_sequence || 0 end)

        %{state | audit_sequence: next_seq}

      {:error, _} ->
        state
    end
  end

  defp restore_audit_sequence(state, path) when is_binary(path) do
    max_seq =
      path
      |> Arvo.Session.Audit.list()
      |> Enum.map(& &1["sequence"])
      |> Enum.filter(&is_integer/1)
      |> Enum.max(fn -> 0 end)

    %{state | audit_sequence: max_seq}
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
              text:
                if(m[:is_error] || m["is_error"], do: String.slice(content, 0, 300), else: nil),
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

  defp recovery_tool?(tool) when is_binary(tool) do
    tool in ["RecallEvidence", "recall_evidence"]
  end

  defp recovery_tool?(_), do: false

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
