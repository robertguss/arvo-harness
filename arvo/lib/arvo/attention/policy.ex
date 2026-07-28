defmodule Arvo.Attention.Policy do
  @moduledoc """
  Pure progressive-attention decisions: stub vs full-hot, fidelity retention,
  exception budget, expand caps, same-path reuse preference.

  No I/O. Agent and Session call this after tool invoke.
  """

  # Conservative defaults — tune via config without product re-brainstorm.
  @default_stub_bytes 4_000
  @default_preview_bytes 400
  @default_fidelity_ttl_turns 2
  @default_max_exception_bytes 80_000
  @default_max_exception_count 8
  @default_expand_cap_bytes 16_000

  @type action :: :stub | :full_hot | :expand_slice

  @doc """
  Decide how a tool result enters model hot context.

  Input map keys (atoms or strings):
  - `:tool`, `:args`, `:text`, `:is_error`
  - `:pinned?` — user pin forces full-hot
  - `:retention` — `%{last_reads, current_turn, fidelity_ttl_turns, edited_paths}`
  - `:budgets` — exception bytes/count used + max overrides
  - `:opts` — threshold overrides (`stub_bytes`, `preview_bytes`, …)
  """
  def decide(input) when is_map(input) do
    text = to_string(get(input, :text) || "")
    is_error? = get(input, :is_error) == true
    pinned? = get(input, :pinned?) == true
    tool = to_string(get(input, :tool) || "")
    args = get(input, :args) || %{}
    retention = get(input, :retention) || %{}
    budgets = get(input, :budgets) || %{}
    opts = get(input, :opts) || %{}

    stub_bytes = opt(opts, budgets, :stub_bytes, @default_stub_bytes)
    preview_bytes = opt(opts, budgets, :preview_bytes, @default_preview_bytes)
    max_ex_bytes = opt(opts, budgets, :max_exception_bytes, @default_max_exception_bytes)
    max_ex_count = opt(opts, budgets, :max_exception_count, @default_max_exception_count)
    used_bytes = get(budgets, :exception_bytes) || 0
    used_count = get(budgets, :exception_count) || 0

    size = byte_size(text)
    path = source_path(tool, args)
    preview = preview(text, preview_bytes)
    retain? = fidelity_retain?(tool, path, retention)
    budget_ok? = under_budget?(size, used_bytes, used_count, max_ex_bytes, max_ex_count)

    cond do
      pinned? ->
        decision(:full_hot, size, preview, false, :pinned, path)

      is_error? and size <= stub_bytes ->
        decision(:full_hot, size, preview, false, :error, path)

      is_error? and budget_ok? ->
        # Large errors full-hot only under exception budget (late-window protection)
        decision(:full_hot, size, preview, true, :error, path)

      is_error? ->
        decision(:stub, size, preview, false, :exception_budget, path)

      size <= stub_bytes ->
        decision(:full_hot, size, preview, false, :small, path)

      retain? and budget_ok? ->
        decision(:full_hot, size, preview, true, :fidelity_retention, path)

      retain? ->
        decision(:stub, size, preview, false, :exception_budget, path)

      true ->
        decision(:stub, size, preview, false, :size, path)
    end
  end

  @doc "Whether expand of `requested_bytes` (or full body) is within cap."
  def expand_allowed?(input) when is_map(input) do
    body = get(input, :body_bytes) || 0
    cap = get(input, :cap_bytes) || @default_expand_cap_bytes
    requested = get(input, :requested_bytes) || body

    if requested <= cap do
      {:ok, :within_cap}
    else
      {:deny, :over_cap}
    end
  end

  def default_expand_cap_bytes, do: @default_expand_cap_bytes
  def default_stub_bytes, do: @default_stub_bytes
  def default_preview_bytes, do: @default_preview_bytes
  def default_fidelity_ttl_turns, do: @default_fidelity_ttl_turns
  def default_max_exception_bytes, do: @default_max_exception_bytes
  def default_max_exception_count, do: @default_max_exception_count

  @doc "Extract path from tool args for read/edit/write; nil otherwise."
  def source_path(tool, args) when tool in ["read", "edit", "write"] do
    p = Map.get(args || %{}, "path") || Map.get(args || %{}, :path)
    if is_binary(p), do: p, else: nil
  end

  def source_path(_, _), do: nil

  @doc "True when retention marks path as edited."
  def path_edited?(path, retention) when is_binary(path) and is_map(retention) do
    edited = Map.get(retention, :edited_paths) || Map.get(retention, "edited_paths") || []
    path in to_mapset(edited)
  end

  def path_edited?(_, _), do: false

  @doc """
  Prefer cold/stub path when an unchanged path already has a cold id (AE7).
  """
  def same_path_preference(input) when is_map(input) do
    cold_id = get(input, :cold_id)
    changed? = get(input, :path_changed?) == true

    if is_binary(cold_id) and cold_id != "" and not changed? do
      :prefer_cold_stub
    else
      :allow_tool
    end
  end

  @doc "Build a stub content string for the model (honest, no fake full body)."
  def stub_content(decision, cold_id) when is_map(decision) and is_binary(cold_id) do
    tool = decision[:tool] || decision["tool"] || "tool"
    size = decision[:size] || decision["size"] || 0
    preview = decision[:preview] || decision["preview"] || ""
    path = decision[:path] || decision["path"]
    path_line = if path, do: " path=#{path}", else: ""

    """
    [cold:#{cold_id} tool=#{tool} bytes=#{size}#{path_line}]
    Full body stored cold; not in model hot context. Ask the user to /recall #{cold_id} (capped) if needed.
    preview:
    #{preview}
    """
    |> String.trim()
  end

  @doc "Update retention map after a tool result decision."
  def update_retention(retention, tool, path, decision, current_turn)
      when is_map(retention) and is_map(decision) do
    last_reads = Map.get(retention, :last_reads) || Map.get(retention, "last_reads") || %{}
    edited = Map.get(retention, :edited_paths) || Map.get(retention, "edited_paths") || MapSet.new()

    edited =
      if tool in ["edit", "write"] and is_binary(path) do
        MapSet.put(to_mapset(edited), path)
      else
        to_mapset(edited)
      end

    last_reads =
      if tool == "read" and is_binary(path) and decision.action == :full_hot and not decision[:is_error] do
        Map.put(last_reads, path, %{turn: current_turn})
      else
        last_reads
      end

    %{
      last_reads: last_reads,
      edited_paths: edited,
      current_turn: current_turn,
      fidelity_ttl_turns:
        Map.get(retention, :fidelity_ttl_turns) ||
          Map.get(retention, "fidelity_ttl_turns") ||
          @default_fidelity_ttl_turns
    }
  end

  # --- internals ---

  defp decision(action, size, preview, fidelity_exception, reason, path) do
    %{
      action: action,
      size: size,
      preview: preview,
      preview_bytes: byte_size(preview),
      fidelity_exception: fidelity_exception,
      reason: reason,
      path: path
    }
  end

  defp fidelity_retain?(tool, path, retention) do
    tool == "read" and is_binary(path) and path != "" and
      not path_edited?(path, retention) and
      within_ttl?(path, retention)
  end

  defp within_ttl?(path, retention) do
    # First successful read of P (no prior record) qualifies for fidelity full-hot.
    last_reads = Map.get(retention, :last_reads) || Map.get(retention, "last_reads") || %{}
    ttl = Map.get(retention, :fidelity_ttl_turns) || Map.get(retention, "fidelity_ttl_turns") || @default_fidelity_ttl_turns
    current = Map.get(retention, :current_turn) || Map.get(retention, "current_turn") || 0

    case Map.get(last_reads, path) do
      nil -> true
      %{turn: t} when is_integer(t) -> current - t <= ttl
      %{"turn" => t} when is_integer(t) -> current - t <= ttl
      _ -> true
    end
  end

  defp under_budget?(size, used_bytes, used_count, max_bytes, max_count) do
    used_bytes + size <= max_bytes and used_count + 1 <= max_count
  end

  defp preview(text, max) when is_binary(text) and is_integer(max) do
    if byte_size(text) <= max do
      text
    else
      binary_part(text, 0, max) <> "…"
    end
  end

  defp get(map, key) when is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp opt(opts, budgets, key, default) do
    get(opts, key) || get(budgets, key) || default
  end

  defp to_mapset(%MapSet{} = s), do: s
  defp to_mapset(list) when is_list(list), do: MapSet.new(list)
  defp to_mapset(_), do: MapSet.new()
end
