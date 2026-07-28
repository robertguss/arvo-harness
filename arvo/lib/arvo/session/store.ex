defmodule Arvo.Session.Store do
  @moduledoc """
  JSONL tree session persistence (SPEC §9).

  Location: `~/.arvo/sessions/<cwd-slug>/<timestamp>_<uuid>.jsonl`
  Every entry is `{id, parent_id, ...}` appended at write time.
  """

  @version 1

  def sessions_root do
    home = System.get_env("HOME") || System.user_home!()
    Path.join([home, ".arvo", "sessions"])
  end

  def cwd_slug(cwd) when is_binary(cwd) do
    cwd
    |> String.replace(~r/[^A-Za-z0-9._-]+/, "_")
    |> String.trim("_")
    |> case do
      "" -> "root"
      s -> s
    end
  end

  @doc "Create a new session file with session_meta as first entry. Returns path."
  def create(cwd, opts \\ []) do
    model = Keyword.get(opts, :model) || "xai:grok-4.5"
    dir = Path.join(sessions_root(), cwd_slug(cwd))
    File.mkdir_p!(dir)
    ts = Calendar.strftime(DateTime.utc_now(), "%Y%m%dT%H%M%SZ")
    uuid = Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
    path = Path.join(dir, "#{ts}_#{uuid}.jsonl")

    profile = Keyword.get(opts, :profile) || "base"
    parent_session_id = Keyword.get(opts, :parent_session_id)

    meta =
      %{
        "id" => new_id(),
        "parent_id" => nil,
        "type" => "session_meta",
        "version" => @version,
        "cwd" => cwd,
        "model" => model,
        "profile" => profile,
        "created_at" => DateTime.utc_now() |> DateTime.to_iso8601()
      }
      |> then(fn m ->
        if parent_session_id, do: Map.put(m, "parent_session_id", parent_session_id), else: m
      end)

    append!(path, meta)
    {:ok, path, meta}
  end

  @doc "Append one entry map. Adds id if missing. Returns the written entry."
  def append!(path, entry) when is_binary(path) and is_map(entry) do
    entry =
      entry
      |> stringify_keys()
      |> Map.put_new("id", new_id())

    line = Jason.encode!(entry)
    File.write!(path, line <> "\n", [:append])
    entry
  end

  @doc "Read all entries from a session file in order."
  def read_all(path) when is_binary(path) do
    case File.read(path) do
      {:ok, body} ->
        body
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          case Jason.decode(line) do
            {:ok, map} -> map
            _ -> nil
          end
        end)
        |> Enum.reject(&is_nil/1)

      {:error, _} ->
        []
    end
  end

  @doc "Validate tree: unique ids, parents exist (or nil), first is session_meta."
  def valid_tree?(entries) when is_list(entries) do
    case entries do
      [%{"type" => "session_meta", "id" => root_id} | rest] ->
        ids = MapSet.new([root_id | Enum.map(rest, & &1["id"])])
        unique? = MapSet.size(ids) == length(entries)

        parents_ok? =
          Enum.all?(rest, fn e ->
            pid = e["parent_id"]
            is_nil(pid) or MapSet.member?(ids, pid) or pid == root_id
          end)

        # parent of rest should exist among ids (including earlier entries)
        parents_exist? =
          Enum.reduce_while(entries, {MapSet.new(), true}, fn e, {seen, _} ->
            pid = e["parent_id"]
            id = e["id"]

            cond do
              is_nil(pid) ->
                {:cont, {MapSet.put(seen, id), true}}

              MapSet.member?(seen, pid) ->
                {:cont, {MapSet.put(seen, id), true}}

              true ->
                {:halt, {seen, false}}
            end
          end)
          |> elem(1)

        unique? and parents_ok? and parents_exist?

      _ ->
        false
    end
  end

  @doc "Tip entry: last non-head_move entry in file (EOF tip — may differ from HEAD)."
  def tip(path) when is_binary(path) do
    case read_all(path) do
      [] -> nil
      entries -> tip(entries)
    end
  end

  def tip(entries) when is_list(entries) do
    last_content_entry(entries)
  end

  @doc """
  Resolve explicit HEAD id from entries.

  Last valid `head_move` sets a rewind base. HEAD is then the latest content
  entry that is that base or a descendant of it (fork after rewind). Otherwise
  HEAD is the last non-`head_move` entry. Corrupt head_id falls back to tip.
  """
  def resolve_head(entries) when is_list(entries) do
    by_id = Map.new(entries, &{&1["id"], &1})

    case last_head_move(entries) do
      {%{"head_id" => base}, idx} when is_binary(base) ->
        if Map.has_key?(by_id, base) do
          subsequent = Enum.drop(entries, idx + 1)

          tip_on_branch =
            subsequent
            |> Enum.reject(&(&1["type"] == "head_move"))
            |> Enum.filter(fn e -> e["id"] == base or descendant_of?(by_id, e["id"], base) end)
            |> List.last()

          case tip_on_branch do
            %{"id" => id} -> id
            _ -> base
          end
        else
          case last_content_entry(entries) do
            %{"id" => id} -> id
            _ -> nil
          end
        end

      _ ->
        case last_content_entry(entries) do
          %{"id" => id} -> id
          _ -> nil
        end
    end
  end

  def resolve_head(path) when is_binary(path), do: resolve_head(read_all(path))

  defp last_head_move(entries) do
    entries
    |> Enum.with_index()
    |> Enum.filter(fn {e, _} -> e["type"] == "head_move" end)
    |> List.last()
  end

  defp descendant_of?(_by_id, id, ancestor_id) when id == ancestor_id, do: true

  defp descendant_of?(by_id, id, ancestor_id) do
    case by_id[id] do
      %{"parent_id" => ^ancestor_id} ->
        true

      %{"parent_id" => pid} when is_binary(pid) ->
        descendant_of?(by_id, pid, ancestor_id)

      _ ->
        false
    end
  end

  @doc "Entry map for current HEAD (or nil)."
  def head_entry(entries) when is_list(entries) do
    case resolve_head(entries) do
      nil -> nil
      id -> Enum.find(entries, &(&1["id"] == id))
    end
  end

  def head_entry(path) when is_binary(path), do: head_entry(read_all(path))

  @doc """
  Append-only HEAD move. Does not rewrite prior lines.
  `parent_id` on the head_move record is the previous HEAD (audit trail).
  """
  def append_head_move!(path, head_id, opts \\ []) when is_binary(path) and is_binary(head_id) do
    parent = Keyword.get(opts, :parent_id)

    append!(path, %{
      "type" => "head_move",
      "parent_id" => parent,
      "head_id" => head_id,
      "at" => DateTime.utc_now() |> DateTime.to_iso8601()
    })
  end

  @doc "Reconstruct chat messages along root → HEAD (product path)."
  def messages_to_head(path) when is_binary(path) do
    messages_to_head(read_all(path))
  end

  def messages_to_head(entries) when is_list(entries) do
    by_id = Map.new(entries, &{&1["id"], &1})
    head_id = resolve_head(entries)

    if is_nil(head_id) do
      []
    else
      chain =
        Stream.unfold(by_id[head_id], fn
          nil -> nil
          e -> {e, by_id[e["parent_id"]]}
        end)
        |> Enum.reverse()

      Enum.flat_map(chain, &entry_to_messages/1)
    end
  end

  @doc "Reconstruct chat messages along the path from root to tip (EOF). Prefer `messages_to_head/1` for product."
  def messages_to_tip(path) do
    entries = read_all(path)
    by_id = Map.new(entries, &{&1["id"], &1})
    tip = last_content_entry(entries)

    if is_nil(tip) do
      []
    else
      chain =
        Stream.unfold(tip, fn
          nil -> nil
          e -> {e, by_id[e["parent_id"]]}
        end)
        |> Enum.reverse()

      Enum.flat_map(chain, &entry_to_messages/1)
    end
  end

  defp last_content_entry(entries) do
    entries
    |> Enum.reject(&(&1["type"] in ["head_move"]))
    |> List.last()
  end

  @doc "List session files for a cwd, newest first."
  def list_for_cwd(cwd) do
    dir = Path.join(sessions_root(), cwd_slug(cwd))

    case File.ls(dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".jsonl"))
        |> Enum.map(&Path.join(dir, &1))
        |> Enum.sort(:desc)

      {:error, _} ->
        []
    end
  end

  @doc """
  Sessions worth resuming: newest first, excluding empty shells (meta-only).

  Boot used to `open_new` before any chat; those empty files sorted as #1 and
  made `/resume 1` useless. Index picker uses this list; path resume still
  accepts any file.
  """
  def list_resumable_for_cwd(cwd) do
    cwd
    |> list_for_cwd()
    |> Enum.filter(&has_message_entries?/1)
  end

  defp has_message_entries?(path) do
    path
    |> read_all()
    |> Enum.any?(fn e -> e["type"] == "message" end)
  end

  def new_id do
    Base.encode16(:crypto.strong_rand_bytes(12), case: :lower)
  end

  @doc "Convert a single session entry into zero-or-more chat messages (tool fields preserved)."
  def entry_to_messages(%{"type" => "message", "incomplete" => true} = e) do
    # Cancel-as-fork leaves incomplete assistant leaves on disk; keep them off the model path.
    if (e["role"] || "user") == "assistant" and (e["content"] || "") == "" do
      []
    else
      entry_to_messages(Map.delete(e, "incomplete"))
    end
  end

  def entry_to_messages(%{"type" => "message"} = e) do
    role = e["role"] || "user"
    content = e["content"] || ""

    base = %{role: role, content: content}

    base =
      if e["tool_call_id"] do
        Map.merge(base, %{
          tool_call_id: e["tool_call_id"],
          name: e["name"],
          is_error: e["is_error"] || false
        })
      else
        base
      end

    base =
      case e["tool_calls"] do
        nil -> base
        [] -> base
        tcs -> Map.put(base, :tool_calls, normalize_tool_calls(tcs))
      end

    [base]
  end

  def entry_to_messages(%{"type" => "compaction"} = e) do
    [%{role: "system", content: "[compacted summary]\n" <> (e["summary"] || "")}]
  end

  def entry_to_messages(_), do: []

  @doc "Flatten session history entries to chat messages for the agent/API."
  def messages_from_history(entries) when is_list(entries) do
    Enum.flat_map(entries, &entry_to_messages/1)
  end

  defp normalize_tool_calls(tcs) when is_list(tcs) do
    Enum.map(tcs, fn tc ->
      tc = if is_map(tc), do: tc, else: %{}

      %{
        id: tc["id"] || tc[:id],
        name: tc["name"] || tc[:name] || get_in(tc, ["function", "name"]),
        arguments: tc["arguments"] || tc[:arguments] || get_in(tc, ["function", "arguments"]) || %{}
      }
    end)
  end

  @doc "Recursively stringify map keys (atom → string). Shared by cold/audit/warm."
  def stringify_keys(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), stringify_val(v)}
      {k, v} -> {k, stringify_val(v)}
    end)
  end

  defp stringify_val(v) when is_map(v), do: stringify_keys(v)
  defp stringify_val(v) when is_list(v), do: Enum.map(v, &stringify_val/1)
  defp stringify_val(v), do: v
end
