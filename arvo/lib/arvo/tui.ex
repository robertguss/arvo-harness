defmodule Arvo.TUI do
  @moduledoc """
  Terminal owner GenServer (SPEC §7). Rendering state derives only from core events.
  Agent logic lives in Arvo.Agent; this module never calls the model directly.
  """
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def state, do: GenServer.call(__MODULE__, :state)
  def handle_event(event), do: GenServer.call(__MODULE__, {:event, event})
  def set_model(model), do: GenServer.call(__MODULE__, {:set_model, model})
  def model, do: GenServer.call(__MODULE__, :model)

  def usage_line do
    GenServer.call(__MODULE__, :usage_line)
  end

  def put_tokens(turn, cumulative, window \\ 500_000) do
    GenServer.call(__MODULE__, {:put_tokens, turn, cumulative, window})
  end

  @doc "Dispatch a slash command. Returns `{:ok, :quit | :handled | :unknown}` result text."
  def slash(cmd, args \\ "") do
    # Device flow blocks on network poll — run outside the GenServer mailbox.
    if cmd == "login" do
      run_login()
    else
      GenServer.call(__MODULE__, {:slash, cmd, args})
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
       mode: :raw_v0,
       model: Map.get(cfg, :default_model) || "xai:grok-4.5",
       profile: Map.get(cfg, :profile) || "base",
       streaming: false,
       buffer: "",
       spinner: false,
       tool_name: nil,
       status: :idle,
       last_error: nil,
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

  def handle_call({:key, key}, _from, state) do
    key = normalize_key(key)

    cond do
      key == :esc and state.status == :running ->
        _ = Arvo.Session.cancel_turn()
        {:reply, :cancelled, %{state | status: :idle, spinner: false, tool_name: nil, streaming: false}}

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

  defp reduce_event(state, {:agent_start, _}), do: %{state | status: :running, buffer: "", spinner: true}
  defp reduce_event(state, {:turn_start, _}), do: %{state | spinner: true, tool_name: nil}
  defp reduce_event(state, {:message_delta, %{text: t}}), do: %{state | streaming: true, buffer: state.buffer <> t, spinner: false}
  defp reduce_event(state, {:tool_call_start, %{name: n}}), do: %{state | spinner: true, tool_name: n}
  defp reduce_event(state, {:tool_call_end, _}), do: %{state | tool_name: nil}
  defp reduce_event(state, {:turn_end, _}), do: %{state | spinner: false, tool_name: nil}
  defp reduce_event(state, {:agent_end, _}), do: %{state | status: :idle, streaming: false, spinner: false}
  defp reduce_event(state, {:agent_error, %{error: e}}), do: %{state | status: :idle, last_error: e, spinner: false}
  defp reduce_event(state, _), do: state

  defp do_slash(state, "help", _) do
    text = """
    Commands:
      /help              this help
      /model [spec]      show or set model (req_llm string, e.g. xai:grok-4.5)
      /login [provider]  device-flow login (default grok)
      /quit              exit
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
    name = String.trim(name)
    active = Arvo.Plugins.Registry.list_active()

    case Arvo.Profiles.switch(name, active) do
      {:ok, result} ->
        {{:ok, :handled, "switched to #{name}: #{inspect(result)}"}, Map.put(state, :profile, name)}

      {:error, reason} ->
        {{:ok, :handled, "profile error: #{inspect(reason)}"}, state}
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
        {n, _} when n >= 1 -> Enum.at(sessions, n - 1)
        _ ->
          # Full path still works for any file (including empty shells).
          if String.ends_with?(arg, ".jsonl"), do: String.trim(arg), else: nil
      end

    case path && Arvo.Session.resume(path) do
      {:ok, %{messages: msgs}} ->
        {{:ok, :handled, "resumed #{Path.basename(path)} (#{length(msgs)} messages)"}, state}

      _ ->
        {{:ok, :handled, "could not resume: #{arg}"}, state}
    end
  end

  defp do_slash(state, "compact", args) do
    instructions = if String.trim(args) == "", do: nil, else: String.trim(args)
    sess = Arvo.Session.get()
    messages = Enum.flat_map(sess.history || [], fn e ->
      if e["type"] == "message" do
        [%{role: e["role"], content: e["content"], id: e["id"]}]
      else
        []
      end
    end)

    result = Arvo.Session.Compaction.compact(messages, sess.history || [], instructions: instructions)

    if sess.path do
      _ = Arvo.Session.record_message(Map.put(result.entry, "role", "system"))
    end

    {{:ok, :handled, "compacted: kept #{length(result.kept_messages)} messages"}, state}
  end

  defp do_slash(state, other, _) do
    {{:ok, :unknown, "unknown command: /#{other}"}, state}
  end

  defp normalize_key(:esc), do: :esc
  defp normalize_key("\e"), do: :esc
  defp normalize_key(:escape), do: :esc
  defp normalize_key(other), do: other
end
