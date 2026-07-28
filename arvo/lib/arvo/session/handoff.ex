defmodule Arvo.Session.Handoff do
  @moduledoc """
  Attention handoff: structured work-delta packet → new session (R15–R16).

  Parent JSONL stays intact. Singleton Session rebinds to the child.
  Idle-only. Fail-closed: parent remains open if child create/seed fails.
  """

  @packet_keys ~w(goal goal_known done not_done paths last_error next_steps parent_session_id)

  @doc "Build handoff packet map from current session history (deterministic v0)."
  def build_packet(opts \\ []) do
    build_packet_from(Arvo.Session.get(), opts)
  end

  @doc """
  Perform handoff: create child session, seed single packet entry, rebind Session+TUI.

  Returns `{:ok, %{path, parent_path, packet}}` or `{:error, reason}`.
  """
  def perform(opts \\ []) do
    # Entire handoff under Session GenServer so start_turn cannot interleave
    # (create/seed/marker/rebind must be atomic vs turn start).
    Arvo.Session.handoff(opts)
  end

  @doc false
  def do_perform_locked(sess, opts) do
    parent_path = sess.path
    packet = build_packet_from(sess, opts)
    cwd = sess.cwd || Application.get_env(:arvo, :cwd) || Arvo.cwd()
    model = sess.model || Application.get_env(:arvo, :default_model) || "xai:grok-4.5"
    profile = sess.profile || "base"
    parent_entry_count = length(sess.history || [])

    try do
      {:ok, child_path, meta} =
        Arvo.Session.Store.create(cwd,
          model: model,
          profile: profile,
          parent_session_id: sess.id
        )

      child_warm = Arvo.Session.Warm.from_packet(packet)

      seed = %{
        "type" => "message",
        "role" => "user",
        "content" => packet_blob(packet),
        "parent_id" => meta["id"],
        "handoff_packet" => true,
        "warm" => child_warm
      }

      written = Arvo.Session.Store.append!(child_path, seed)
      child_entries = [meta, written]

      # Parent marker is best-effort append-only (ignore missing parent file)
      if is_binary(parent_path) do
        try do
          _ =
            Arvo.Session.Store.append!(parent_path, %{
              "type" => "handoff_marker",
              "parent_id" => sess.last_id,
              "child_path" => child_path,
              "child_session_id" => meta["id"]
            })

          :ok
        rescue
          _ -> :ok
        end
      end

      {:ok,
       %{
         path: child_path,
         parent_path: parent_path,
         packet: packet,
         parent_entry_count: parent_entry_count + 1,
         child_messages: Arvo.Session.Store.messages_to_head(child_entries),
         rebind: %{
           id: meta["id"],
           path: child_path,
           last_id: written["id"],
           history: child_entries,
           cwd: cwd,
           model: meta["model"],
           profile: meta["profile"],
           tokens: Arvo.Session.Tokens.new(),
           warm: child_warm
         }
       }}
    rescue
      e ->
        {:error, Exception.message(e)}
    end
  end

  def packet_blob(packet) when is_map(packet) do
    goal_known = Map.get(packet, "goal_known") == true

    goal_line =
      if goal_known and is_binary(packet["goal"]),
        do: packet["goal"],
        else: "(unknown — not set by user/pin/handoff)"

    """
    [handoff packet]
    goal: #{goal_line}
    goal_known: #{goal_known}
    done: #{packet["done"]}
    not_done: #{packet["not_done"]}
    paths: #{inspect(packet["paths"])}
    last_error: #{packet["last_error"]}
    next_steps: #{packet["next_steps"]}
    parent_session_id: #{packet["parent_session_id"]}
    """
  end

  def packet_keys, do: @packet_keys

  defp build_packet_from(sess, opts) do
    messages = Arvo.Session.Store.messages_to_head(sess.history || [])
    assts = Enum.filter(messages, &((&1[:role] || &1["role"]) == "assistant"))

    warm = Map.get(sess, :warm) || Map.get(sess, "warm") || Arvo.Session.Warm.empty()
    warm = Arvo.Session.Warm.normalize(warm)
    warm_fields = Arvo.Session.Warm.to_packet_fields(warm)

    # Goal: opts pin > live warm only. Never invent from last user ack (R9 honesty).
    {goal, goal_known} =
      cond do
        is_binary(Keyword.get(opts, :goal)) and String.trim(Keyword.get(opts, :goal)) != "" ->
          {String.slice(String.trim(Keyword.get(opts, :goal)), 0, 200), true}

        warm_fields["goal_known"] and is_binary(warm_fields["goal"]) ->
          {warm_fields["goal"], true}

        true ->
          {nil, false}
      end

    paths = Keyword.get(opts, :paths) || warm_fields["paths"] || []
    last_error = Keyword.get(opts, :last_error) || warm_fields["last_error"] || ""

    %{
      # Keep goal nil when unknown so rehydrate cannot invent a goal string (R9)
      "goal" => if(goal_known, do: goal, else: nil),
      "goal_known" => goal_known,
      "done" => Keyword.get(opts, :done) || summarize_done(assts),
      "not_done" =>
        Keyword.get(opts, :not_done) || if(goal_known, do: goal, else: "(goal unknown)"),
      "paths" => paths,
      "last_error" => last_error,
      "next_steps" => Keyword.get(opts, :next_steps) || "Continue from handoff packet.",
      "parent_session_id" => sess.id
    }
  end

  defp summarize_done(assts) do
    assts
    |> Enum.take(-3)
    |> Enum.map_join("; ", fn m ->
      String.slice(to_string(m[:content] || m["content"] || ""), 0, 80)
    end)
  end
end
