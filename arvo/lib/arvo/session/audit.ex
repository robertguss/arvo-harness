defmodule Arvo.Session.Audit do
  @moduledoc """
  Append-only progressive-attention audit trail beside the open session.

  Events for Rob, tests, and evals — not bulk-injected into model context.
  """

  @events ~w(
    store_cold stub_in_hot full_hot fidelity_exception warm_update expand
    same_path_reinvoke denied_expand
  )a

  def events, do: @events

  @doc "Audit JSONL path for a session file."
  def path(session_path) when is_binary(session_path) do
    Path.rootname(session_path) <> ".audit.jsonl"
  end

  @doc """
  Append one audit event. `type` is an atom or string.
  Always adds `at` timestamp if missing.
  """
  def append(session_path, type, fields \\ %{})
      when is_binary(session_path) and is_map(fields) do
    type_str = type |> to_string()

    event =
      fields
      |> stringify_keys()
      |> Map.put("type", type_str)
      |> Map.put_new("at", DateTime.utc_now() |> DateTime.to_iso8601())

    File.write!(path(session_path), Jason.encode!(event) <> "\n", [:append])
    {:ok, event}
  rescue
    e -> {:error, Exception.message(e)}
  end

  @doc "Read all audit events for a session."
  def list(session_path) when is_binary(session_path) do
    case File.read(path(session_path)) do
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

  @doc """
  Aggregate counters from audit events for tests/evals.

  Keys: `store_cold`, `stub_in_hot`, `full_hot`, `full_ingest_bytes`,
  `fidelity_exception`, `fidelity_exception_bytes`, `warm_update`, `expand`,
  `same_path_reinvoke`, `denied_expand`.
  """
  def metrics(session_path) when is_binary(session_path) do
    metrics_from_events(list(session_path))
  end

  def metrics_from_events(events) when is_list(events) do
    Enum.reduce(events, empty_metrics(), fn e, acc ->
      type = e["type"]
      size = e["size"] || e["bytes"] || 0
      size = if is_integer(size), do: size, else: 0

      acc =
        case type do
          "store_cold" -> Map.update!(acc, :store_cold, &(&1 + 1))
          "stub_in_hot" -> Map.update!(acc, :stub_in_hot, &(&1 + 1))
          "full_hot" ->
            acc
            |> Map.update!(:full_hot, &(&1 + 1))
            |> Map.update!(:full_ingest_bytes, &(&1 + size))

          "fidelity_exception" ->
            acc
            |> Map.update!(:fidelity_exception, &(&1 + 1))
            |> Map.update!(:fidelity_exception_bytes, &(&1 + size))

          "warm_update" -> Map.update!(acc, :warm_update, &(&1 + 1))
          "expand" -> Map.update!(acc, :expand, &(&1 + 1))
          "same_path_reinvoke" -> Map.update!(acc, :same_path_reinvoke, &(&1 + 1))
          "denied_expand" -> Map.update!(acc, :denied_expand, &(&1 + 1))
          _ -> acc
        end

      acc
    end)
  end

  def empty_metrics do
    %{
      store_cold: 0,
      stub_in_hot: 0,
      full_hot: 0,
      full_ingest_bytes: 0,
      fidelity_exception: 0,
      fidelity_exception_bytes: 0,
      warm_update: 0,
      expand: 0,
      same_path_reinvoke: 0,
      denied_expand: 0
    }
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
