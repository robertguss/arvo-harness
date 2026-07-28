defmodule Arvo.TUI do
  @moduledoc """
  Terminal state GenServer (SPEC §7). Rendering state derives only from core events.
  Agent logic lives in Arvo.Agent; this module never calls the model directly.

  Focus (`Arvo.TUI.Focus`) is the product interactive surface; this GenServer is
  the pure projector + slash/key dispatch.
  """
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def state, do: GenServer.call(__MODULE__, :state)

  @doc """
  Project a core event. Uses cast so the turn Task cannot deadlock on TUI mailbox.
  Returns `:ok` immediately.
  """
  def handle_event(event) do
    GenServer.cast(__MODULE__, {:event, event})
    :ok
  end

  @doc "Synchronous event reduce (tests)."
  def handle_event_sync(event), do: GenServer.call(__MODULE__, {:event, event})

  def set_model(model), do: GenServer.call(__MODULE__, {:set_model, model})
  def model, do: GenServer.call(__MODULE__, :model)

  def usage_line do
    GenServer.call(__MODULE__, :usage_line)
  end

  def put_tokens(turn, cumulative, window \\ 500_000) do
    # Cast so Session never GenServer.calls TUI while holding Session (AB-BA with slash).
    GenServer.cast(__MODULE__, {:put_tokens, turn, cumulative, window})
  end

  def append_user(text) when is_binary(text) do
    GenServer.call(__MODULE__, {:append, %{kind: :user, text: text}})
  end

  def append_system(text) when is_binary(text) do
    GenServer.call(__MODULE__, {:append, %{kind: :system, text: text}})
  end

  def reset_idle do
    GenServer.call(__MODULE__, :reset_idle)
  end

  @doc """
  Atomically claim product turn UI state if idle.

  Prevents Focus double-Enter races before `agent_start` arrives.
  Returns `:ok` or `{:error, :busy}`.
  """
  def try_begin_turn do
    GenServer.call(__MODULE__, :try_begin_turn)
  end

  @doc "Dispatch a slash command. Returns `{:ok, :quit | :handled | :unknown}` result text."
  def slash(cmd, args \\ "") do
    # Device flow blocks on network poll — run outside the GenServer mailbox.
    if cmd == "login" do
      run_login()
    else
      GenServer.call(__MODULE__, {:slash, cmd, args}, 30_000)
    end
  end

  @doc false
  def run_login(opts \\ []) do
    case Arvo.Auth.DeviceFlow.login(opts) do
      {:ok, _creds} ->
        _ = Arvo.Auth.TokenManager.reload()
        {:ok, :handled, "login ok — credentials saved to ~/.arvo/auth.json"}

      {:error, reason} ->
        msg = if is_binary(reason), do: reason, else: inspect(reason)
        {:ok, :handled, "login failed: #{msg}"}
    end
  end

  @doc "Apply a keypress while a turn may be running. Esc cancels."
  def key(key) when is_atom(key) or is_binary(key) do
    GenServer.call(__MODULE__, {:key, key})
  end

  @doc "Queue steering text (typing during a turn)."
  def steer(text), do: Arvo.Session.steer(text)

  @impl true
  def init(_opts) do
    cfg = Application.get_env(:arvo, :config) || %{}

    {:ok,
     %{
       mode: :focus,
       model: Map.get(cfg, :default_model) || "xai:grok-4.5",
       profile: Map.get(cfg, :profile) || "base",
       streaming: false,
       buffer: "",
       spinner: false,
       tool_name: nil,
       status: :idle,
       last_error: nil,
       input: "",
       transcript: [],
       tokens: %{turn: 0, cumulative: 0, window: 500_000},
       # Focus polish: expand/focus/slash palette / session tree
       focus_idx: nil,
       expand_all: nil,
       palette: nil,
       tree: nil
     }}
  end

  @impl true
  def handle_call(:state, _from, state), do: {:reply, state, state}
  def handle_call(:model, _from, state), do: {:reply, state.model, state}

  def handle_call(:usage_line, _from, state) do
    t = state.tokens
    line = "tokens turn=#{t.turn} cum=#{t.cumulative}/#{t.window}"
    {:reply, line, state}
  end

  def handle_call({:put_tokens, turn, cum, window}, _from, state) do
    # Keep call path for tests that still sync; cast is the product path.
    {:reply, :ok, %{state | tokens: %{turn: turn, cumulative: cum, window: window}}}
  end

  def handle_call({:set_model, model}, _from, state) when is_binary(model) do
    {:reply, :ok, %{state | model: model}}
  end

  def handle_call({:event, event}, _from, state) do
    {:reply, :ok, reduce_event(state, event)}
  end

  def handle_call({:append, entry}, _from, state) do
    {:reply, :ok, %{state | transcript: state.transcript ++ [entry]}}
  end

  def handle_call(:reset_idle, _from, state) do
    {:reply, :ok,
     %{
       state
       | status: :idle,
         spinner: false,
         tool_name: nil,
         streaming: false,
         buffer: "",
         last_error: nil,
         tree: nil,
         palette: nil
     }}
  end

  def handle_call(:try_begin_turn, _from, state) do
    # Local claim only — Session.start_turn is the real mutex.
    if state.status == :running do
      {:reply, {:error, :busy}, state}
    else
      {:reply, :ok, %{state | status: :running, spinner: true, buffer: "", last_error: nil}}
    end
  end

  def handle_call({:key, key}, _from, state) do
    key = normalize_key(key)
    {reply, state} = handle_key(state, key)
    {:reply, reply, state}
  end

  def handle_call({:slash, cmd, args}, _from, state) do
    {reply, state} = do_slash(state, cmd, args)
    {:reply, reply, state}
  end

  @impl true
  def handle_cast({:put_tokens, turn, cum, window}, state) do
    {:noreply, %{state | tokens: %{turn: turn, cumulative: cum, window: window}}}
  end

  def handle_cast({:event, event}, state) do
    {:noreply, reduce_event(state, event)}
  end

  @doc false
  def handle_key(state, key) do
    cond do
      # Cancel turn beats tree/palette close so Esc mid-turn always works.
      key == :esc and state.status == :running ->
        _ = Arvo.Session.cancel_turn()

        {:cancelled,
         %{
           state
           | status: :idle,
             spinner: false,
             tool_name: nil,
             streaming: false,
             buffer: "",
             palette: nil,
             tree: nil
         }}

      # Tree mode takes priority over palette / focus expand (KTD4 routing).
      key == :esc and state[:tree] != nil ->
        {:ok, %{state | tree: nil}}

      key == :esc and state[:palette] != nil ->
        {:ok, %{state | palette: nil}}

      key == :esc ->
        {:ignored, state}

      key == :ctrl_e and state[:tree] == nil ->
        {:ok, toggle_expand_all(state)}

      key in [:up, :down] and state[:tree] != nil ->
        {:ok, move_tree_sel(state, key)}

      key in [:up, :down] and state[:palette] != nil ->
        {:ok, move_palette(state, key)}

      key in [:up, :down] and state.status != :running ->
        {:ok, move_focus(state, key)}

      key == :enter and state[:tree] != nil ->
        commit_tree_jump(state)

      key in [:enter, :space] and state.status != :running and state[:input] in [nil, ""] and
          is_integer(state[:focus_idx]) and state[:tree] == nil ->
        {:ok, toggle_focus_row(state)}

      true ->
        {:ok, state}
    end
  end

  defp reduce_event(state, {:agent_start, _}) do
    %{state | status: :running, buffer: "", spinner: true, last_error: nil, focus_idx: nil}
  end

  defp reduce_event(state, {:turn_start, _}), do: %{state | spinner: true, tool_name: nil}

  defp reduce_event(state, {:thinking_start, _}) do
    now = System.monotonic_time(:millisecond)
    expanded = default_expanded(state, true)

    entry = %{
      kind: :thought,
      text: "",
      started_at: now,
      ended_at: nil,
      expanded: expanded,
      live: true
    }

    %{state | spinner: true, transcript: state.transcript ++ [entry]}
  end

  defp reduce_event(state, {:thinking_delta, %{text: t}}) do
    t = String.replace(to_string(t), "\e", "")
    transcript = update_last_thought(state.transcript, fn th -> %{th | text: th.text <> t} end)
    %{state | spinner: true, transcript: transcript}
  end

  defp reduce_event(state, {:thinking_end, _}) do
    now = System.monotonic_time(:millisecond)

    transcript =
      update_last_thought(state.transcript, fn th ->
        # Keep reasoning text on-screen after thinking ends so scrollback stays
        # useful; user can still collapse via Ctrl+E / per-row toggle.
        keep_open? = is_binary(th.text) and th.text != ""
        %{th | live: false, ended_at: now, expanded: default_expanded(state, keep_open?)}
      end)

    %{state | transcript: transcript}
  end

  defp reduce_event(state, {:message_delta, %{text: t}}) do
    # Defer full sanitize to agent_end/paint (per-token regex is hot-path bloat)
    t = String.replace(t, "\e", "")
    %{state | streaming: true, buffer: state.buffer <> t, spinner: false}
  end

  defp reduce_event(state, {:tool_call_start, ev}) do
    name = Map.get(ev, :name) || "tool"
    id = Map.get(ev, :id)
    args = Map.get(ev, :arguments) || %{}
    summary = Arvo.TUI.Activity.summarize(name, args)
    expanded = default_expanded(state, false)

    entry = %{
      kind: :activity,
      id: id,
      name: name,
      summary: summary,
      status: :running,
      detail: nil,
      expanded: expanded
    }

    %{state | spinner: true, tool_name: name, transcript: state.transcript ++ [entry]}
  end

  defp reduce_event(state, {:tool_call_end, ev}) do
    name = Map.get(ev, :name) || state.tool_name || "tool"
    id = Map.get(ev, :id)
    err? = Map.get(ev, :is_error, false)
    text = Map.get(ev, :text) || if(err?, do: "error", else: "ok")
    action = Map.get(ev, :attention_action) || :full_hot
    cold_id = Map.get(ev, :cold_id)
    model_text = Map.get(ev, :model_text)

    label =
      case action do
        :stub -> " [model:stub#{if cold_id, do: " cold:" <> cold_id, else: ""}]"
        :full_hot -> " [model:full]"
        other -> " [model:#{other}]"
      end

    detail =
      if action == :stub and is_binary(model_text) and model_text != text do
        text <>
          "\n— dual-view: model saw —\n" <>
          model_text <>
          "\n— end dual-view#{label} —"
      else
        text <> label
      end

    status = if err?, do: :error, else: :ok
    expanded = default_expanded(state, false)

    transcript =
      update_last_activity(state.transcript, name, id, fn entry ->
        entry
        |> Map.put(:status, status)
        |> Map.put(:detail, detail)
        |> Map.put(:expanded, expanded)
        |> Map.put(:is_error, err?)
        |> Map.put(:attention_action, action)
        |> Map.put(:cold_id, cold_id)
      end)

    %{state | tool_name: nil, transcript: transcript}
  end

  defp reduce_event(state, {:turn_end, _}), do: %{state | spinner: false, tool_name: nil}

  defp reduce_event(state, {:agent_end, _}) do
    transcript =
      if state.buffer != "" do
        text = sanitize_terminal_text(state.buffer)
        state.transcript ++ [%{kind: :assistant, text: text}]
      else
        state.transcript
      end

    # Ensure any live thought is closed but keep body visible when present
    transcript =
      update_last_thought(transcript, fn th ->
        if th.live do
          keep_open? = is_binary(th.text) and th.text != ""

          %{
            th
            | live: false,
              ended_at: th.ended_at || System.monotonic_time(:millisecond),
              expanded: default_expanded(state, keep_open?)
          }
        else
          th
        end
      end)

    %{
      state
      | status: :idle,
        streaming: false,
        spinner: false,
        buffer: "",
        transcript: transcript
    }
  end

  defp reduce_event(state, {:agent_error, %{error: e}}) do
    %{
      state
      | status: :idle,
        last_error: e,
        spinner: false,
        streaming: false,
        tool_name: nil
    }
  end

  defp reduce_event(state, _), do: state

  defp default_expanded(%{expand_all: true}, _live_default), do: true
  defp default_expanded(%{expand_all: false}, _live_default), do: false
  defp default_expanded(_, live_default), do: live_default

  defp update_last_thought(transcript, fun) do
    idx =
      transcript
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.find_value(fn
        {%{kind: :thought}, i} -> i
        _ -> nil
      end)

    if is_integer(idx) do
      List.update_at(transcript, idx, fun)
    else
      transcript
    end
  end

  defp update_last_activity(transcript, name, id, fun) do
    idx =
      transcript
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.find_value(fn
        {%{kind: :activity, id: ^id}, i} when not is_nil(id) -> i
        {%{kind: :activity, name: ^name, status: :running}, i} -> i
        {%{kind: :tool, name: ^name}, i} -> i
        _ -> nil
      end)

    if is_integer(idx) do
      List.update_at(transcript, idx, fun)
    else
      entry = fun.(%{kind: :activity, name: name, summary: name, status: :ok, detail: nil, expanded: false})
      transcript ++ [entry]
    end
  end

  defp toggle_expand_all(state) do
    next =
      case state[:expand_all] do
        true -> false
        false -> true
        nil -> true
      end

    transcript =
      Enum.map(state.transcript, fn
        %{kind: k} = e when k in [:thought, :activity, :tool] ->
          Map.put(e, :expanded, next)

        other ->
          other
      end)

    %{state | expand_all: next, transcript: transcript}
  end

  defp focusable_indices(transcript) do
    transcript
    |> Enum.with_index()
    |> Enum.filter(fn
      {%{kind: k}, _} when k in [:thought, :activity, :tool] -> true
      _ -> false
    end)
    |> Enum.map(&elem(&1, 1))
  end

  defp move_focus(state, dir) do
    idxs = focusable_indices(state.transcript)

    if idxs == [] do
      state
    else
      cur = state[:focus_idx]
      pos = Enum.find_index(idxs, &(&1 == cur))

      next_pos =
        case {dir, pos} do
          {:up, nil} -> length(idxs) - 1
          {:down, nil} -> 0
          {:up, 0} -> 0
          {:up, p} -> p - 1
          {:down, p} when p >= length(idxs) - 1 -> length(idxs) - 1
          {:down, p} -> p + 1
        end

      %{state | focus_idx: Enum.at(idxs, next_pos)}
    end
  end

  defp toggle_focus_row(state) do
    idx = state[:focus_idx]

    if is_integer(idx) and idx < length(state.transcript) do
      transcript =
        List.update_at(state.transcript, idx, fn
          %{kind: k} = e when k in [:thought, :activity, :tool] ->
            Map.put(e, :expanded, !Map.get(e, :expanded, false))

          other ->
            other
        end)

      %{state | transcript: transcript, expand_all: nil}
    else
      state
    end
  end

  defp move_palette(state, dir) do
    pal = state.palette || %{query: "", selected: 0}
    items = Arvo.TUI.SlashMenu.filter(pal[:query] || "")
    sel = pal[:selected] || 0

    sel2 =
      case dir do
        :up -> max(sel - 1, 0)
        :down -> min(sel + 1, max(length(items) - 1, 0))
      end

    %{state | palette: %{pal | selected: sel2}}
  end

  defp move_tree_sel(state, dir) do
    tree = state.tree || %{nodes: [], selected: 0, scroll: 0}
    nodes = tree[:nodes] || []
    sel = tree[:selected] || 0
    n = length(nodes)

    sel2 =
      case dir do
        :up -> max(sel - 1, 0)
        :down -> min(sel + 1, max(n - 1, 0))
      end

    # Keep selection in a painted window (cap large trees)
    scroll = tree[:scroll] || 0
    window = tree[:window] || 12
    scroll2 =
      cond do
        sel2 < scroll -> sel2
        sel2 >= scroll + window -> sel2 - window + 1
        true -> scroll
      end

    %{state | tree: %{tree | selected: sel2, scroll: max(scroll2, 0)}}
  end

  defp commit_tree_jump(state) do
    tree = state.tree || %{}
    nodes = tree[:nodes] || []
    sel = tree[:selected] || 0

    case Enum.at(nodes, sel) do
      %{jumpable?: false} ->
        msg = "not a jump target (tools orient only)"
        {:ok, %{state | transcript: state.transcript ++ [%{kind: :system, text: msg}]}}

      %{id: id, jumpable?: true} when is_binary(id) ->
        if Arvo.Session.turn_in_progress?() do
          msg = "jump rejected: turn in progress (idle-only)"
          {:ok, %{state | transcript: state.transcript ++ [%{kind: :system, text: msg}]}}
        else
          case Arvo.Session.jump_to(id) do
            {:ok, %{head_id: _hid, messages: msgs}} ->
              state =
                state
                |> rehydrate_transcript_from_messages(msgs)
                |> Map.put(:tree, nil)
                |> Map.put(:buffer, "")
                |> Map.put(:streaming, false)

              nav = "Navigated to selected point."
              {:ok, %{state | transcript: state.transcript ++ [%{kind: :system, text: nav}]}}

            {:error, :turn_in_progress} ->
              msg = "jump rejected: turn in progress (idle-only)"
              {:ok, %{state | transcript: state.transcript ++ [%{kind: :system, text: msg}]}}

            {:error, reason} ->
              msg = "jump failed: #{inspect(reason)}"
              {:ok, %{state | transcript: state.transcript ++ [%{kind: :system, text: msg}]}}
          end
        end

      _ ->
        {:ok, %{state | tree: nil}}
    end
  end

  @doc false
  def rehydrate_transcript_from_messages(state, messages) when is_list(messages) do
    entries =
      Enum.flat_map(messages, fn msg ->
        role = msg[:role] || msg["role"] || "user"
        content = msg[:content] || msg["content"] || ""

        cond do
          role == "user" ->
            [%{kind: :user, text: content}]

          role == "assistant" ->
            # Incomplete empty assistants omitted by messages_to_head already
            if content == "" and (msg[:tool_calls] || msg["tool_calls"]) in [nil, []] do
              []
            else
              entry = %{kind: :assistant, text: content}

              entry =
                if msg[:incomplete] || msg["incomplete"] do
                  Map.put(entry, :aborted, true)
                else
                  entry
                end

              [entry]
            end

          role == "tool" ->
            name = msg[:name] || msg["name"] || "tool"
            summary = Arvo.TUI.Activity.summarize(name, %{})
            err? = msg[:is_error] || msg["is_error"] || false

            [
              %{
                kind: :activity,
                name: name,
                summary: summary,
                status: if(err?, do: :error, else: :ok),
                detail: content,
                expanded: false
              }
            ]

          true ->
            []
        end
      end)

    %{state | transcript: entries, focus_idx: nil}
  end

  @doc "Open or update slash palette from current input draft."
  def put_palette(state, input) when is_binary(input) do
    if String.starts_with?(input, "/") do
      query = String.trim_leading(input, "/")
      # drop args after space for filter of command name
      q = query |> String.split(" ", parts: 2) |> hd()
      items = Arvo.TUI.SlashMenu.filter(q)
      sel = Arvo.TUI.SlashMenu.clamp_selected(items, (state[:palette] || %{})[:selected] || 0)
      %{state | input: input, palette: %{query: q, selected: sel}}
    else
      %{state | input: input, palette: nil}
    end
  end

  @doc "Selected palette command name or nil."
  def palette_selection(state) do
    case state[:palette] do
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

  defp do_slash(state, "help", _) do
    plugin_cmds =
      case Arvo.Plugins.Registry.commands() do
        map when map_size(map) > 0 ->
          names =
            map
            |> Map.keys()
            |> Enum.filter(&String.contains?(&1, ":"))
            |> Enum.sort()
            |> Enum.map_join("\n", &("      /" <> &1))

          if names == "", do: "", else: "\n  Plugin commands:\n#{names}\n"

        _ ->
          ""
      end

    text = """
    Commands:
      /help              this help
      /model [spec]      show or set model (req_llm string, e.g. xai:grok-4.5)
      /profile [name]    list profiles, or switch workflow profile
      /login [provider]  device-flow login (default grok)
      /new               start a fresh session (clear transcript)
      /resume [n|path]   list sessions, or resume by index/path
      /tree              session tree navigator — browse DAG and jump HEAD
      /rewind [n]        legacy: move HEAD back n steps (prefer /tree)
      /handoff           new session with work-delta packet (no silent compact)
      /inspect [id]      warm + cold list; /inspect <cold-id> full body
      /memory [id]       alias for /inspect
      /recall <id>       expand cold entry into view under size caps
      /compact [focus]   power: summarize older turns (optional focus text)
      /quit              exit#{plugin_cmds}
    Keys (Focus): Enter send · Esc cancel turn · / for slash · /tree navigate
    """

    {{:ok, :handled, text}, state}
  end

  defp do_slash(state, "tree", _) do
    case Arvo.Session.get() do
      %{path: path, history: history} when is_binary(path) and is_list(history) ->
        nodes = Arvo.Session.Store.tree_nodes(history)

        if nodes == [] do
          {{:ok, :handled, "session tree empty (no messages yet)"}, %{state | tree: nil}}
        else
          # Prefer current HEAD selection when present
          head_idx =
            Enum.find_index(nodes, & &1.head?) ||
              max(length(nodes) - 1, 0)

          tree = %{
            nodes: nodes,
            selected: head_idx,
            scroll: max(head_idx - 5, 0),
            window: 12
          }

          {{:ok, :tree, "Session Tree (#{length(nodes)} nodes)"},
           %{state | tree: tree, palette: nil}}
        end

      _ ->
        {{:ok, :handled, "no open session — start chatting or /resume first"}, state}
    end
  end

  defp do_slash(state, "model", "") do
    {{:ok, :handled, "model: #{state.model}"}, state}
  end

  defp do_slash(state, "model", spec) do
    spec = String.trim(spec)
    {{:ok, :handled, "model set to #{spec}"}, %{state | model: spec}}
  end

  defp do_slash(state, "quit", _) do
    {{:ok, :quit, "bye"}, state}
  end

  defp do_slash(state, "profile", "") do
    active = Arvo.Plugins.Registry.list_active()
    current = state[:profile] || "base"

    lines =
      Arvo.Profiles.list()
      |> Enum.map(fn name ->
        mark = if name == current, do: "*", else: " "
        "#{mark} #{name}"
      end)

    text = "Profiles (active=#{current}, plugins=#{inspect(active)}):\n" <> Enum.join(lines, "\n")
    {{:ok, :handled, text}, state}
  end

  defp do_slash(state, "profile", name) do
    # Idle-only: reject while turn in progress (KTD 13)
    if Arvo.Session.turn_in_progress?() do
      {{:ok, :handled, "profile switch rejected: turn in progress (idle-only)"}, state}
    else
      name = String.trim(name)
      active = Arvo.Plugins.Registry.list_active()

      case Arvo.Profiles.switch(name, active) do
        {:ok, result} ->
          Application.put_env(:arvo, :active_profile, name)

          {{:ok, :handled, "switched to #{name}: #{inspect(result)}"},
           Map.put(state, :profile, name)}

        {:error, reason} ->
          {{:ok, :handled, "profile error: #{inspect(reason)}"}, state}
      end
    end
  end

  defp do_slash(state, "new", _) do
    # Idle-only: refuse while a product turn is running (same class as profile/resume).
    if Arvo.Session.turn_in_progress?() do
      {{:ok, :handled, "new session rejected: turn in progress (idle-only)"}, state}
    else
      cwd = Application.get_env(:arvo, :cwd) || Arvo.cwd()

      opts =
        []
        |> then(fn o ->
          if is_binary(state.model), do: Keyword.put(o, :model, state.model), else: o
        end)
        |> then(fn o ->
          if is_binary(state[:profile]), do: Keyword.put(o, :profile, state[:profile]), else: o
        end)

      case Arvo.Session.open_new(cwd, opts) do
        {:ok, path} ->
          state = fresh_ui_state(state)

          {{:ok, :handled, "new session → #{Path.basename(path)}"},
           %{
             state
             | transcript: [%{kind: :system, text: "new session → #{Path.basename(path)}"}]
           }}

        {:error, :turn_in_progress} ->
          {{:ok, :handled, "new session rejected: turn in progress (idle-only)"}, state}

        {:error, reason} ->
          {{:ok, :handled, "new session failed: #{inspect(reason)}"}, state}
      end
    end
  end

  defp do_slash(state, "resume", "") do
    cwd = Application.get_env(:arvo, :cwd) || Arvo.cwd()
    sessions = Arvo.Session.Store.list_resumable_for_cwd(cwd)

    text =
      case sessions do
        [] ->
          "No sessions for this project."

        list ->
          list
          |> Enum.with_index(1)
          |> Enum.map_join("\n", fn {path, i} -> "#{i}. #{Path.basename(path)}" end)
          |> then(&("Sessions (use /resume <n> or path):\n" <> &1))
      end

    {{:ok, :handled, text}, state}
  end

  defp do_slash(state, "resume", arg) do
    cwd = Application.get_env(:arvo, :cwd) || Arvo.cwd()
    sessions = Arvo.Session.Store.list_resumable_for_cwd(cwd)

    path =
      case Integer.parse(String.trim(arg)) do
        {n, _} when n >= 1 ->
          Enum.at(sessions, n - 1)

        _ ->
          if String.ends_with?(arg, ".jsonl"), do: String.trim(arg), else: nil
      end

    case path && Arvo.Session.resume(path) do
      {:ok, %{messages: msgs} = resumed} ->
        state = rehydrate_from_resume(state, resumed)
        {{:ok, :handled, "resumed #{Path.basename(path)} (#{length(msgs)} messages)"}, state}

      _ ->
        {{:ok, :handled, "could not resume: #{arg}"}, state}
    end
  end

  defp do_slash(state, "rewind", args) do
    steps =
      case Integer.parse(String.trim(args || "")) do
        {n, _} when n >= 1 -> n
        _ -> 1
      end

    case Arvo.Session.rewind(steps) do
      {:ok, %{head_id: hid, messages: msgs}} ->
        state =
          state
          |> rehydrate_transcript_from_messages(msgs)
          |> Map.put(:tree, nil)
          |> Map.put(:buffer, "")
          |> Map.put(:streaming, false)

        msg =
          "rewound #{steps} step(s); HEAD=#{String.slice(hid, 0, 8)}… (legacy — prefer /tree)"

        state = %{state | transcript: state.transcript ++ [%{kind: :system, text: msg}]}
        {{:ok, :handled, msg}, state}

      {:ok, %{head_id: hid}} ->
        msg =
          "rewound #{steps} step(s); HEAD=#{String.slice(hid, 0, 8)}… (legacy — prefer /tree)"

        {{:ok, :handled, msg}, state}

      {:error, reason} ->
        {{:ok, :handled, "rewind failed: #{inspect(reason)}"}, state}
    end
  end

  defp do_slash(state, "handoff", _) do
    case Arvo.Session.Handoff.perform() do
      {:ok, %{path: path, packet: packet}} ->
        state = %{
          state
          | status: :idle,
            spinner: false,
            tool_name: nil,
            streaming: false,
            buffer: "",
            last_error: nil,
            tokens: %{turn: 0, cumulative: 0, window: 500_000},
            transcript:
              state.transcript ++ [%{kind: :system, text: "handoff → new session (parent intact)"}]
        }

        {{:ok, :handled,
          "handoff ok → #{Path.basename(path)} (parent_session_id=#{packet["parent_session_id"]})"},
         state}

      {:error, reason} ->
        {{:ok, :handled, "handoff failed: #{inspect(reason)}"}, state}
    end
  end

  defp do_slash(state, cmd, args) when cmd in ["inspect", "memory"] do
    arg = String.trim(args || "")
    snap = Arvo.Session.inspect_attention()

    text =
      if arg == "" do
        format_inspect_summary(snap)
      else
        case Arvo.Session.inspect_cold(arg) do
          {:ok, body} ->
            "cold #{arg} (#{byte_size(body)} bytes):\n" <> String.slice(body, 0, 8_000)

          {:error, :no_session} ->
            "no open session"

          {:error, :not_found} ->
            "cold id not found: #{arg}"

          {:error, reason} ->
            "inspect failed: #{inspect(reason)}"
        end
      end

    {{:ok, :handled, text}, state}
  end

  defp do_slash(state, "recall", args) do
    id = String.trim(args || "")

    if id == "" do
      {{:ok, :handled, "usage: /recall <cold-id>"}, state}
    else
      case Arvo.Session.recall(id, actor: :user) do
        {:ok, slice} ->
          # Inject into session history so next TurnContext / model turn sees the expand
          _ =
            Arvo.Session.record_message(%{
              role: "system",
              content: "[expanded cold:#{id}]\n" <> slice
            })

          {{:ok, :handled, "expanded #{id} into session (#{byte_size(slice)} bytes):\n" <> slice},
           state}

        {:error, :not_found} ->
          {{:ok, :handled, "recall failed: cold id not found (#{id})"}, state}

        {:error, :over_cap} ->
          {{:ok, :handled, "recall denied: over expand cap for #{id}"}, state}

        {:error, reason} ->
          {{:ok, :handled, "recall failed: #{inspect(reason)}"}, state}
      end
    end
  end

  defp do_slash(state, "compact", args) do
    instructions = if String.trim(args) == "", do: nil, else: String.trim(args)
    sess = Arvo.Session.get()

    # Compact attention on HEAD chain only (not abandoned tips after rewind)
    messages = Arvo.Session.Store.messages_to_head(sess.history || [])

    result = Arvo.Session.Compaction.compact(messages, sess.history || [], instructions: instructions)

    if sess.path do
      _ = Arvo.Session.record_message(Map.put(result.entry, "role", "system"))
    end

    {{:ok, :handled, "compacted: kept #{length(result.kept_messages)} messages"}, state}
  end

  defp do_slash(state, other, args) do
    cmds = Arvo.Plugins.Registry.commands()

    case Map.get(cmds, other) || Map.get(cmds, String.trim("#{other}")) do
      nil ->
        {{:ok, :unknown, "unknown command: /#{other}"}, state}

      %{handler: handler} = cmd when is_function(handler, 1) ->
        result = handler.(args)
        {{:ok, :handled, "plugin #{cmd.plugin}:#{cmd.name}: #{inspect(result)}"}, state}

      %{handler: handler} = cmd when is_function(handler, 0) ->
        result = handler.()
        {{:ok, :handled, "plugin #{cmd.plugin}:#{cmd.name}: #{inspect(result)}"}, state}

      %{name: n, plugin: p} ->
        {{:ok, :handled, "plugin command /#{p}:#{n} (no handler; acknowledged)"}, state}

      _ ->
        {{:ok, :unknown, "unknown command: /#{other}"}, state}
    end
  end

  defp format_inspect_summary(snap) when is_map(snap) do
    warm = snap.warm || %{}
    cold = snap.cold || []
    metrics = snap.metrics || %{}

    goal =
      if warm["goal_known"],
        do: warm["goal"],
        else: "(unknown)"

    cold_lines =
      cold
      |> Enum.take(-20)
      |> Enum.map_join("\n", fn e ->
        "  #{e["id"]} tool=#{e["tool"]} bytes=#{e["size"]} path=#{e["source_path"] || "-"}"
      end)

    cold_lines = if cold_lines == "", do: "  (none)", else: cold_lines

    """
    Progressive attention: #{if snap.progressive_attention, do: "on", else: "off"}
    Warm:
      goal: #{goal}
      paths: #{inspect(Enum.take(warm["paths"] || [], 12))}
      last_error: #{warm["last_error"] || ""}
    Cold entries (#{length(cold)}):
    #{cold_lines}
    Metrics: store=#{metrics[:store_cold] || 0} stub=#{metrics[:stub_in_hot] || 0} full_hot=#{metrics[:full_hot] || 0} full_ingest_bytes=#{metrics[:full_ingest_bytes] || 0} same_path_reinvoke=#{metrics[:same_path_reinvoke] || 0} expand=#{metrics[:expand] || 0}
    /inspect <id> for full cold body; /recall <id> to expand under caps.
    """
    |> String.trim()
  end

  defp fresh_ui_state(state) do
    %{
      state
      | status: :idle,
        spinner: false,
        tool_name: nil,
        streaming: false,
        buffer: "",
        last_error: nil,
        focus_idx: nil,
        expand_all: nil,
        palette: nil,
        tree: nil,
        tokens: %{turn: 0, cumulative: 0, window: 500_000},
        transcript: []
    }
  end

  defp rehydrate_from_resume(state, resumed) do
    tokens = resumed[:tokens] || resumed["tokens"]

    state =
      if tokens do
        cum = tokens.cumulative_total || 0
        turn = (tokens.turn_input || 0) + (tokens.turn_output || 0)
        %{state | tokens: %{turn: turn, cumulative: cum, window: 500_000}}
      else
        state
      end

    state =
      case resumed[:model] || resumed["model"] do
        m when is_binary(m) -> %{state | model: m}
        _ -> state
      end

    case resumed[:profile] || resumed["profile"] do
      p when is_binary(p) and p != "" and p != "base" ->
        _ = Arvo.Profiles.reapply(p)
        Map.put(state, :profile, p)

      p when is_binary(p) ->
        Map.put(state, :profile, p)

      _ ->
        state
    end
  end


  defp normalize_key(:esc), do: :esc
  defp normalize_key("\e"), do: :esc
  defp normalize_key(:escape), do: :esc
  defp normalize_key(:ctrl_e), do: :ctrl_e
  defp normalize_key("\x05"), do: :ctrl_e
  defp normalize_key(:up), do: :up
  defp normalize_key(:down), do: :down
  defp normalize_key(:enter), do: :enter
  defp normalize_key(:space), do: :space
  defp normalize_key(" "), do: :space
  defp normalize_key(other), do: other

  # Strip ESC and C0 controls (keep tab/newline) so model text cannot drive the TTY
  defp sanitize_terminal_text(t) when is_binary(t) do
    t
    |> String.replace(~r/\e\[[0-9;?]*[A-Za-z]/, "")
    |> String.replace(~r/\e\][^\a\e]*(?:\a|\e\\)?/, "")
    |> String.replace(~r/[\x00-\x08\x0b\x0c\x0e-\x1f]/, "")
  end

  defp sanitize_terminal_text(other), do: other
end
