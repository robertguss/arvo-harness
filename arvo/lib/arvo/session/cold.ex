defmodule Arvo.Session.Cold do
  @moduledoc """
  Session-complete cold store for full tool bodies (progressive attention).

  Bodies live as sidecars beside the open session JSONL (`<session>.cold/`),
  not as temp bash spills. v1 completeness is session-scoped.
  """

  @doc "Directory for cold bodies for a session JSONL path."
  def cold_dir(session_path) when is_binary(session_path) do
    Path.rootname(session_path) <> ".cold"
  end

  @doc """
  Store a full body under a stable id. Returns `{:ok, entry}` with metadata
  (id, size, tool, kind, source_path, created_at). JSONL index holds pointers.
  """
  def store(session_path, body, meta \\ %{})
      when is_binary(session_path) and is_binary(body) and is_map(meta) do
    id = meta_get(meta, :id) || Arvo.Session.Store.new_id()
    dir = cold_dir(session_path)
    ensure_dir!(dir)

    body_path = Path.join(dir, id <> ".body")
    File.write!(body_path, body)

    digest =
      meta_get(meta, :digest) ||
        (:crypto.hash(:sha256, body) |> Base.encode16(case: :lower))

    entry =
      %{
        "id" => id,
        "size" => byte_size(body),
        "digest" => digest,
        "body_path" => body_path,
        "kind" => meta_get(meta, :kind) || "tool_result",
        "tool" => meta_get(meta, :tool),
        "source_path" => meta_get(meta, :source_path),
        "tool_call_id" => meta_get(meta, :tool_call_id),
        "preview" => meta_get(meta, :preview),
        "created_at" => DateTime.utc_now() |> DateTime.to_iso8601()
      }
      |> Map.reject(fn {_k, v} -> is_nil(v) end)

    index_path = Path.join(dir, "index.jsonl")
    File.write!(index_path, Jason.encode!(entry) <> "\n", [:append])

    {:ok, entry}
  rescue
    e -> {:error, Exception.message(e)}
  end

  @doc "Fetch full body by id. Returns `{:ok, body}` or `{:error, :not_found}`."
  def fetch(session_path, id) when is_binary(session_path) and is_binary(id) do
    body_path = Path.join(cold_dir(session_path), id <> ".body")

    case File.read(body_path) do
      {:ok, body} -> {:ok, body}
      {:error, :enoent} -> {:error, :not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc "Read up to max_bytes of a cold body without loading the whole file when large."
  def fetch_slice(session_path, id, max_bytes)
      when is_binary(session_path) and is_binary(id) and is_integer(max_bytes) and max_bytes > 0 do
    body_path = Path.join(cold_dir(session_path), id <> ".body")

    case File.stat(body_path) do
      {:ok, %File.Stat{size: size}} when size <= max_bytes ->
        fetch(session_path, id)
        |> case do
          {:ok, body} -> {:ok, body, size}
          err -> err
        end

      {:ok, %File.Stat{size: size}} ->
        case File.open(body_path, [:read, :binary], fn io -> IO.binread(io, max_bytes) end) do
          {:ok, data} when is_binary(data) -> {:ok, data, size}
          {:ok, :eof} -> {:ok, "", size}
          {:error, reason} -> {:error, reason}
        end

      {:error, :enoent} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "List cold entry metadata for the session (newest last)."
  def list(session_path) when is_binary(session_path) do
    Arvo.Session.Store.read_all(Path.join(cold_dir(session_path), "index.jsonl"))
  end

  @doc "Lookup entry metadata by id."
  def get_entry(session_path, id) when is_binary(session_path) and is_binary(id) do
    case Enum.find(list(session_path), &(&1["id"] == id)) do
      nil -> {:error, :not_found}
      entry -> {:ok, entry}
    end
  end

  @doc "Find most recent cold entry for a source path (e.g. file path from read)."
  def find_by_source_path(session_path, source_path)
      when is_binary(session_path) and is_binary(source_path) do
    session_path
    |> list()
    |> Enum.reverse()
    |> Enum.find(&(&1["source_path"] == source_path))
  end

  defp ensure_dir!(dir), do: File.mkdir_p!(dir)

  defp meta_get(meta, key) when is_atom(key) do
    Map.get(meta, key) || Map.get(meta, Atom.to_string(key))
  end
end
