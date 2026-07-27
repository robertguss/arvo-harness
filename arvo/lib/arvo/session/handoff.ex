defmodule Arvo.Session.Handoff do
  @moduledoc """
  Attention handoff: structured work-delta packet → new session (R15–R16).

  Parent JSONL stays intact. Singleton Session rebinds to the child.
  Idle-only. Fail-closed: parent remains open if child create/seed fails.
  """

  @packet_keys ~w(goal done not_done paths last_error next_steps parent_session_id)

  @doc "Build handoff packet map from current session history (deterministic v0)."
  def build_packet(opts \\ []) do
    sess = Arvo.Session.get()
    history = sess.history || []
    messages = Arvo.Session.Store.messages_to_head(history)

    users = Enum.filter(messages, &((&1[:role] || &1["role"]) == "user"))
    assts = Enum.filter(messages, &((&1[:role] || &1["role"]) == "assistant"))

    goal =
      Keyword.get(opts, :goal) ||
        case List.last(users) do
          nil -> "continue work"
          m -> String.slice(to_string(m[:content] || m["content"] || ""), 0, 200)
        end

    last_asst =
      case List.last(assts) do
        nil -> ""
        m -> String.slice(to_string(m[:content] || m["content"] || ""), 0, 400)
      end

    %{
      "goal" => goal,
      "done" => Keyword.get(opts, :done) || summarize_done(assts),
      "not_done" => Keyword.get(opts, :not_done) || goal,
      "paths" => Keyword.get(opts, :paths) || [],
      "last_error" => Keyword.get(opts, :last_error) || last_error(sess),
      "next_steps" => Keyword.get(opts, :next_steps) || "Continue from handoff packet.",
      "parent_session_id" => sess.id,
      "last_assistant_excerpt" => last_asst
    }
  end

  @doc """
  Perform handoff: create child session, seed single packet entry, rebind Session+TUI.

  Returns `{:ok, %{path, parent_path, packet}}` or `{:error, reason}`.
  """
  def perform(opts \\ []) do
    # Entire handoff runs under Session GenServer so start_turn cannot interleave
    # between idle check, child create, marker, and rebind (closes TOCTOU).
    Arvo.Session.handoff(opts)
  end

  @doc false
  def do_perform_locked(sess, opts) do
    parent_path = sess.path
    packet = build_packet_from(sess, opts)
    cwd = sess.cwd || Application.get_env(:arvo, :cwd) || Arvo.cwd()
    model = sess.model || Application.get_env(:arvo, :default_model) || "xai:grok-4.5"
    profile = sess.profile || "base"

    try do
      {:ok, child_path, meta} =
        Arvo.Session.Store.create(cwd,
          model: model,
          profile: profile,
          parent_session_id: sess.id
        )

      seed = %{
        "type" => "message",
        "role" => "user",
        "content" => packet_blob(packet),
        "parent_id" => meta["id"],
        "handoff_packet" => true
      }

      written = Arvo.Session.Store.append!(child_path, seed)
      child_entries = [meta, written]

      # Optional parent marker (append-only)
      if is_binary(parent_path) and File.exists?(parent_path) do
        _ =
          Arvo.Session.Store.append!(parent_path, %{
            "type" => "handoff_marker",
            "parent_id" => sess.last_id,
            "child_path" => child_path,
            "child_session_id" => meta["id"]
          })
      end

      parent_now = Arvo.Session.Store.read_all(parent_path)

      {:ok,
       %{
         path: child_path,
         parent_path: parent_path,
         packet: packet,
         parent_entry_count: length(parent_now),
         child_messages: Arvo.Session.Store.messages_to_head(child_entries),
         rehydrate_tui: true,
         rebind: %{
           id: meta["id"],
           path: child_path,
           last_id: written["id"],
           history: child_entries,
           cwd: cwd,
           model: meta["model"],
           profile: meta["profile"],
           tokens: Arvo.Session.Tokens.new(),
           steering: [],
           turn_task: nil,
           turn_result: nil
         }
       }}
    rescue
      e ->
        {:error, Exception.message(e)}
    end
  end

  defp build_packet_from(sess, opts) do
    history = sess.history || []
    messages = Arvo.Session.Store.messages_to_head(history)

    users = Enum.filter(messages, &((&1[:role] || &1["role"]) == "user"))
    assts = Enum.filter(messages, &((&1[:role] || &1["role"]) == "assistant"))

    goal =
      Keyword.get(opts, :goal) ||
        case List.last(users) do
          nil -> "continue work"
          m -> String.slice(to_string(m[:content] || m["content"] || ""), 0, 200)
        end

    last_asst =
      case List.last(assts) do
        nil -> ""
        m -> String.slice(to_string(m[:content] || m["content"] || ""), 0, 400)
      end

    %{
      "goal" => goal,
      "done" => Keyword.get(opts, :done) || summarize_done(assts),
      "not_done" => Keyword.get(opts, :not_done) || goal,
      "paths" => Keyword.get(opts, :paths) || [],
      "last_error" => Keyword.get(opts, :last_error) || "",
      "next_steps" => Keyword.get(opts, :next_steps) || "Continue from handoff packet.",
      "parent_session_id" => sess.id,
      "last_assistant_excerpt" => last_asst
    }
  end

  def packet_blob(packet) when is_map(packet) do
    """
    [handoff packet]
    goal: #{packet["goal"]}
    done: #{packet["done"]}
    not_done: #{packet["not_done"]}
    paths: #{inspect(packet["paths"])}
    last_error: #{packet["last_error"]}
    next_steps: #{packet["next_steps"]}
    parent_session_id: #{packet["parent_session_id"]}
    """
  end

  def packet_keys, do: @packet_keys

  defp summarize_done(assts) do
    assts
    |> Enum.take(-3)
    |> Enum.map_join("; ", fn m ->
      String.slice(to_string(m[:content] || m["content"] || ""), 0, 80)
    end)
  end

  defp last_error(_sess), do: ""
end

