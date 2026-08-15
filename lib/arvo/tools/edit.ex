defmodule Arvo.Tools.Edit do
  @moduledoc "search_replace edit with exact-once match and whitespace-tolerant fallback (SPEC §3)."


  use Jido.Action,
    name: "edit",
    description:
      "Replace old_string with new_string in a file. old_string must match exactly once unless replace_all is true. On miss, re-read and retry.",
    category: "tools",
    tags: ["filesystem", "edit"],
    vsn: "0.1.0",
    schema: [
      path: [type: :string, required: true, doc: "File to edit"],
      old_string: [type: :string, required: true, doc: "Exact text to find"],
      new_string: [type: :string, required: true, doc: "Replacement text"],
      replace_all: [
        type: :boolean,
        required: false,
        default: false,
        doc: "Replace every occurrence when true"
      ]
    ]

  @doc false
  def spec, do: Arvo.Tool.spec_from_jido(__MODULE__)

  @impl Jido.Action
  def run(params, ctx) do
    path = resolve_path(params[:path] || params["path"], ctx)
    old_string = params[:old_string] || params["old_string"]
    new_string = params[:new_string] || params["new_string"]
    replace_all? = params[:replace_all] || params["replace_all"] || false

    with :ok <- ensure_exists(path),
         {:ok, content} <- File.read(path),
         {:ok, updated, count} <- apply_edit(content, old_string, new_string, replace_all?),
         :ok <- File.write(path, updated) do
      {:ok, "Edited #{path} (#{count} replacement#{if count == 1, do: "", else: "s"})"}
    end
  end

  defp apply_edit(content, old_string, new_string, replace_all?) do
    case count_exact(content, old_string) do
      n when n > 0 ->
        do_replace(content, old_string, new_string, replace_all?, n, :exact)

      0 ->
        case whitespace_tolerant_match(content, old_string) do
          {:ok, exact_old, n} ->
            do_replace(content, exact_old, new_string, replace_all?, n, :whitespace)

          :none ->
            {:error,
             "old_string not found in file — file may have changed — re-read and retry"}

          :ambiguous ->
            {:error,
             "old_string matched multiple times with whitespace-tolerant matching — file may have changed — re-read and retry"}
        end
    end
  end

  defp do_replace(content, old_string, new_string, true, n, _mode) when n >= 1 do
    updated = String.replace(content, old_string, new_string)
    {:ok, updated, n}
  end

  defp do_replace(content, old_string, new_string, false, 1, _mode) do
    updated = String.replace(content, old_string, new_string, global: false)
    {:ok, updated, 1}
  end

  defp do_replace(_content, _old, _new, false, n, _mode) when n > 1 do
    {:error,
     "old_string matched #{n} times; must match exactly once unless replace_all is true — re-read and retry"}
  end

  defp count_exact(content, old_string) do
    content
    |> :binary.matches(old_string)
    |> length()
  end

  # Collapse internal runs of whitespace in both haystack windows and needle for fallback.
  defp whitespace_tolerant_match(content, old_string) do
    needle = collapse_ws(old_string)

    if needle == "" do
      :none
    else
      # Scan line windows and multi-line windows by normalizing whole content positions
      matches = find_ws_matches(content, needle)

      case matches do
        [] -> :none
        [one] -> {:ok, one, 1}
        many when length(many) > 1 -> :ambiguous
      end
    end
  end

  defp find_ws_matches(content, needle) do
    # Walk content; for each start index, expand until collapsed form matches needle length-ish
    len = String.length(content)
    needle_len = String.length(needle)

    Enum.reduce(0..(max(len - 1, 0)), [], fn start, acc ->
      # Limit window to reasonable size: needle length * 3 (whitespace expansion)
      max_window = min(len - start, max(needle_len * 4, needle_len + 64))

      case match_window(content, start, max_window, needle) do
        nil -> acc
        exact -> [exact | acc]
      end
    end)
    |> Enum.reverse()
    |> Enum.uniq()
  end

  defp match_window(_content, _start, max_window, _needle) when max_window <= 0, do: nil

  defp match_window(content, start, max_window, needle) do
    # Grow window until collapsed equals needle or exceeds
    Enum.find_value(1..max_window, fn size ->
      slice = String.slice(content, start, size)

      if collapse_ws(slice) == needle do
        slice
      else
        nil
      end
    end)
  end

  defp collapse_ws(s) do
    s
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end

  defp resolve_path(path, ctx) when is_binary(path) do
    if Path.type(path) == :absolute do
      path
    else
      cwd = Map.get(ctx || %{}, :cwd) || Map.get(ctx || %{}, "cwd") || File.cwd!()
      Path.expand(path, cwd)
    end
  end

  defp ensure_exists(path) do
    if File.exists?(path), do: :ok, else: {:error, "File not found: #{path}"}
  end
end
