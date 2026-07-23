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

    meta = %{
      "id" => new_id(),
      "parent_id" => nil,
      "type" => "session_meta",
      "version" => @version,
      "cwd" => cwd,
      "model" => model,
      "created_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    }

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

  @doc "Tip entry: last entry in file (resume-from-tip)."
  def tip(path) do
    case read_all(path) do
      [] -> nil
      entries -> List.last(entries)
    end
  end

  @doc "Reconstruct chat messages along the path from root to tip."
  def messages_to_tip(path) do
    entries = read_all(path)
    by_id = Map.new(entries, &{&1["id"], &1})
    tip = List.last(entries)

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

  defp stringify_keys(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), stringify_val(v)}
      {k, v} -> {k, stringify_val(v)}
    end)
  end

  defp stringify_val(v) when is_map(v), do: stringify_keys(v)
  defp stringify_val(v) when is_list(v), do: Enum.map(v, &stringify_val/1)
  defp stringify_val(v), do: v
end
