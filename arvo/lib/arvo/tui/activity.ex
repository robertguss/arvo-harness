defmodule Arvo.TUI.Activity do
  @moduledoc """
  Compact tool activity summaries for Focus (verb · target).
  """

  @doc """
  One-line summary for a tool invocation.

  Examples:
  - bash · ls -la arvo
  - read · lib/arvo/tui.ex
  - edit · render.ex
  """
  @spec summarize(String.t() | atom(), map() | keyword() | nil) :: String.t()
  def summarize(name, args \\ %{})

  def summarize(name, args) when is_atom(name), do: summarize(Atom.to_string(name), args)

  def summarize(name, args) when is_binary(name) do
    args = normalize_args(args)
    target = target_for(name, args)

    if target == "" do
      name
    else
      name <> " · " <> target
    end
  end

  def summarize(name, _), do: to_string(name)

  defp target_for("bash", args), do: first_string(args, ["command", :command]) |> collapse_ws()
  defp target_for("read", args), do: first_string(args, ["path", :path, "file", :file])
  defp target_for("write", args), do: first_string(args, ["path", :path, "file", :file])
  defp target_for("edit", args), do: first_string(args, ["path", :path, "file", :file])

  defp target_for(_name, args) do
    args
    |> Map.values()
    |> Enum.find_value("", fn
      v when is_binary(v) and v != "" -> collapse_ws(v)
      _ -> nil
    end)
  end

  defp first_string(args, keys) do
    Enum.find_value(keys, "", fn k ->
      case Map.get(args, k) do
        v when is_binary(v) -> v
        _ -> nil
      end
    end)
  end

  defp normalize_args(nil), do: %{}
  defp normalize_args(args) when is_map(args), do: args
  defp normalize_args(args) when is_list(args), do: Map.new(args)
  defp normalize_args(_), do: %{}

  defp collapse_ws(s) when is_binary(s) do
    s
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
