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
    GenServer.call(__MODULE__, {:put_tokens, turn, cumulative, window})
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
       tokens: %{turn: 0, cumulative: 0, window: 500_000}
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
         last_error: nil
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

    cond do
      key == :esc and state.status == :running ->
        _ = Arvo.Session.cancel_turn()

        # Drop uncommitted streaming buffer; do not retract a transcript row already
        # promoted by :agent_end (that path sets status :idle first).
        {:reply, :cancelled,
         %{state | status: :idle, spinner: false, tool_name: nil, streaming: false, buffer: ""}}

      key == :esc ->
        {:reply, :ignored, state}

      true ->
        {:reply, :ok, state}
    end
  end

  def handle_call({:slash, cmd, args}, _from, state) do
    {reply, state} = do_slash(state, cmd, args)
    {:reply, reply, state}
  end

  @impl true
  def handle_cast({:event, event}, state) do
    {:noreply, reduce_event(state, event)}
  end

  defp reduce_event(state, {:agent_start, _}) do
    %{state | status: :running, buffer: "", spinner: true, last_error: nil}
  end

  defp reduce_event(state, {:turn_start, _}), do: %{state | spinner: true, tool_name: nil}

  defp reduce_event(state, {:message_delta, %{text: t}}) do
    # Defer full sanitize to agent_end/paint (per-token regex is hot-path bloat)
    t = String.replace(t, "\e", "")
    %{state | streaming: true, buffer: state.buffer <> t, spinner: false}
  end

  defp reduce_event(state, {:tool_call_start, %{name: n}}) do
    entry = %{kind: :tool, name: n, text: "running…", folded: true}
    %{state | spinner: true, tool_name: n, transcript: state.transcript ++ [entry]}
  end

  defp reduce_event(state, {:tool_call_end, ev}) do
    name = Map.get(ev, :name) || state.tool_name || "tool"
    err? = Map.get(ev, :is_error, false)
    text = Map.get(ev, :text) || if(err?, do: "error", else: "ok")

    transcript =
      update_last_tool(state.transcript, name, %{
        kind: :tool,
        name: name,
        text: text,
        folded: true,
        is_error: err?
      })

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

  defp update_last_tool(transcript, name, entry) do
    idx =
      transcript
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.find_value(fn
        {%{kind: :tool, name: ^name}, i} -> i
        _ -> nil
      end)

    if is_integer(idx) do
      List.replace_at(transcript, idx, entry)
    else
      transcript ++ [entry]
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
      /resume [n|path]   list sessions, or resume by index/path
      /rewind [n]        move HEAD back n steps (default 1); next msg forks
      /handoff           new session with work-delta packet (no silent compact)
      /compact [focus]   power: summarize older turns (optional focus text)
      /quit              exit#{plugin_cmds}
    Keys (Focus): Enter send · Esc cancel turn · / for slash
    """

    {{:ok, :handled, text}, state}
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
      {:ok, %{head_id: hid}} ->
        {{:ok, :handled, "rewound #{steps} step(s); HEAD=#{String.slice(hid, 0, 8)}…"}, state}

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
