defmodule Arvo.TUI.SlashMenu do
  @moduledoc """
  Filterable slash-command catalog for the Focus palette.
  """

  @builtins [
    {"help", "Show commands and keys"},
    {"model", "Show or set model (e.g. xai:grok-4.5)"},
    {"profile", "List or switch workflow profile"},
    {"login", "Device-flow login (default grok)"},
    {"new", "Start a fresh session (clear transcript)"},
    {"resume", "List sessions or resume by index/path"},
    {"tree", "Session tree navigator — browse and jump (HEAD)"},
    {"rewind", "Legacy: move HEAD back n steps (prefer /tree)"},
    {"handoff", "New session with work-delta packet"},
    {"inspect", "Warm + cold list; /inspect <id> full body"},
    {"memory", "Alias for /inspect"},
    {"recall", "Expand cold entry into session under caps"},
    {"compact", "Summarize older turns (optional focus)"},
    {"quit", "Exit Focus"}
  ]

  @doc "All commands as `{name, description}` (builtins + plugin)."
  @spec catalog() :: [{String.t(), String.t()}]
  def catalog do
    plugins =
      case Arvo.Plugins.Registry.commands() do
        map when is_map(map) ->
          map
          |> Map.keys()
          |> Enum.filter(&String.contains?(&1, ":"))
          |> Enum.sort()
          |> Enum.map(fn name ->
            desc =
              case Map.get(map, name) do
                %{description: d} when is_binary(d) and d != "" -> d
                %{"description" => d} when is_binary(d) and d != "" -> d
                _ -> "plugin command"
              end

            {name, desc}
          end)

        _ ->
          []
      end

    @builtins ++ plugins
  end

  @doc """
  Filter catalog by query (substring on name, case-insensitive).
  Empty query returns all. Selected index is clamped.
  """
  @spec filter(String.t()) :: [{String.t(), String.t()}]
  def filter(query) when is_binary(query) do
    q =
      query
      |> String.trim_leading("/")
      |> String.downcase()

    if q == "" do
      catalog()
    else
      Enum.filter(catalog(), fn {name, desc} ->
        String.contains?(String.downcase(name), q) or
          String.contains?(String.downcase(desc), q)
      end)
    end
  end

  @doc "Clamp selection into list bounds."
  def clamp_selected(_items, sel) when sel < 0, do: 0
  def clamp_selected([], _sel), do: 0

  def clamp_selected(items, sel) do
    max(0, min(sel, length(items) - 1))
  end
end
