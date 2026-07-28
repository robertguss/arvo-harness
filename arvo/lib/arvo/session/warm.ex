defmodule Arvo.Session.Warm do
  @moduledoc """
  Live structured warm work-delta for progressive attention.

  Deterministic fields from tool/user-valid sources. Goal only when a
  product-valid writer set it (last user task line, pin, opts).
  """

  @empty %{
    "goal" => nil,
    "goal_known" => false,
    "paths" => [],
    "last_commands" => [],
    "last_error" => nil,
    "failures" => []
  }

  def empty, do: @empty

  @doc "Normalize a warm map to string keys with defaults."
  def normalize(nil), do: empty()

  def normalize(map) when is_map(map) do
    Map.merge(empty(), stringify_keys(map))
  end

  @doc """
  Update warm from a completed tool result.

  `meta` may include: tool, args, is_error, text (truncated), path, exit_code.
  Returns the same map reference when nothing changed.
  """
  def update_from_tool(warm, meta) when is_map(warm) and is_map(meta) do
    warm = normalize(warm)
    tool = to_string(get(meta, :tool) || "")
    args = get(meta, :args) || %{}
    is_error? = get(meta, :is_error) == true
    text = to_string(get(meta, :text) || "")
    path = get(meta, :path) || Arvo.Attention.Policy.source_path(tool, args)

    bash? = tool == "bash"

    # True no-op: no path, not bash, not error
    if (not is_binary(path) or path == "") and not bash? and not is_error? do
      warm
    else
      paths =
        if is_binary(path) and path != "" do
          if path in warm["paths"], do: warm["paths"], else: [path | warm["paths"]] |> Enum.take(40)
        else
          warm["paths"]
        end

      last_commands =
        if bash? do
          cmd = Map.get(args, "command") || Map.get(args, :command) || ""
          exit_note = if is_error?, do: "err", else: "ok"
          entry = %{"command" => String.slice(to_string(cmd), 0, 200), "status" => exit_note}
          [entry | warm["last_commands"]] |> Enum.take(12)
        else
          warm["last_commands"]
        end

      {last_error, failures} =
        if is_error? do
          err = String.slice(text, 0, 300)
          fail = %{"tool" => tool, "path" => path, "summary" => err}
          {err, [fail | warm["failures"]] |> Enum.take(10)}
        else
          {warm["last_error"], warm["failures"]}
        end

      if paths == warm["paths"] and last_commands == warm["last_commands"] and
           last_error == warm["last_error"] and failures == warm["failures"] do
        warm
      else
        %{
          warm
          | "paths" => paths,
            "last_commands" => last_commands,
            "last_error" => last_error,
            "failures" => failures
        }
      end
    end
  end

  @doc """
  Set goal from a product-valid writer. Never invents goal from free-form LLM warm.
  """
  def set_goal(warm, goal) when is_map(warm) do
    warm = normalize(warm)

    cond do
      is_binary(goal) and String.trim(goal) != "" ->
        %{warm | "goal" => String.slice(String.trim(goal), 0, 200), "goal_known" => true}

      true ->
        %{warm | "goal" => nil, "goal_known" => false}
    end
  end

  @doc "Compact warm block for hot inject (budgeted)."
  def format_for_hot(warm) when is_map(warm) do
    warm = normalize(warm)

    goal_line =
      if warm["goal_known"] do
        "goal: #{warm["goal"]}"
      else
        "goal: (unknown — not set by user/pin/handoff)"
      end

    paths =
      warm["paths"]
      |> Enum.take(15)
      |> Enum.join(", ")

    fails =
      warm["failures"]
      |> Enum.take(3)
      |> Enum.map_join("; ", fn f ->
        "#{f["tool"] || "?"}#{if f["path"], do: " " <> f["path"], else: ""}: #{f["summary"]}"
      end)

    cmds =
      warm["last_commands"]
      |> Enum.take(5)
      |> Enum.map_join("; ", fn c -> "#{c["status"]}: #{c["command"]}" end)

    """
    [warm work-delta]
    #{goal_line}
    paths: #{paths}
    last_error: #{warm["last_error"] || ""}
    recent_failures: #{fails}
    recent_commands: #{cmds}
    """
    |> String.trim()
  end

  @doc "Packet fields for handoff snapshot."
  def to_packet_fields(warm) when is_map(warm) do
    warm = normalize(warm)

    goal =
      if warm["goal_known"], do: warm["goal"], else: nil

    %{
      "goal" => goal,
      "goal_known" => warm["goal_known"],
      "paths" => warm["paths"] || [],
      "last_error" => warm["last_error"] || ""
    }
  end

  @doc "Rehydrate warm from a handoff packet (child session seed)."
  def from_packet(packet) when is_map(packet) do
    packet = stringify_keys(packet)
    goal = packet["goal"]
    known = packet["goal_known"]

    known =
      cond do
        known == true -> true
        known == false -> false
        is_binary(goal) and String.trim(goal) != "" and goal != "continue work" -> true
        true -> false
      end

    empty()
    |> Map.put("paths", List.wrap(packet["paths"]))
    |> Map.put("last_error", packet["last_error"] || nil)
    |> then(fn w ->
      if known, do: set_goal(w, goal), else: %{w | "goal" => nil, "goal_known" => false}
    end)
  end

  defp get(map, key) when is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp stringify_keys(map), do: Arvo.Session.Store.stringify_keys(map)
end
