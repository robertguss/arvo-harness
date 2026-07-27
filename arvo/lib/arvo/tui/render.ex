defmodule Arvo.TUI.Render do
  @moduledoc """
  Pure Focus layout projector: ghost strip + transcript + input + footer.
  No model calls — state in, ANSI string out.
  """

  alias Arvo.TUI.Theme

  @doc "Render full screen frame from TUI state map."
  def frame(state, opts \\ []) do
    width = Keyword.get(opts, :width, 80)
    height = Keyword.get(opts, :height, 24)

    ghost = ghost_line(state, width)
    footer = footer_line(state)
    input = input_line(state, width)

    reserved = 4
    body_h = max(height - reserved, 3)
    body = transcript_lines(state, body_h, width)

    Enum.join([ghost, "" | body] ++ ["", input, footer], "\n")
  end

  def ghost_line(state, width \\ 80) do
    model = state[:model] || "xai:?"
    profile = state[:profile] || "base"
    tokens = state[:tokens] || %{cumulative: 0, window: 500_000}
    cum = tokens[:cumulative] || 0
    win = tokens[:window] || 500_000
    status = status_label(state)

    line = " #{model} · #{profile} · ctx #{cum}/#{win} · #{status}"
    Theme.dim(String.slice(line, 0, width))
  end

  def footer_line(state) do
    base = "Enter send · Ctrl+J newline · Esc cancel · / slash"

    case state[:status] do
      :running -> Theme.accent(" running · Esc cancels ") <> Theme.muted(base)
      _ -> Theme.muted(base)
    end
  end

  def input_line(state, width \\ 80) do
    draft = state[:input] || ""
    prefix = if state[:status] == :running, do: "… ", else: "› "
    Theme.bold(prefix) <> String.slice(draft, 0, max(width - 2, 10))
  end

  def transcript_lines(state, max_lines, width) do
    lines = state[:transcript] || []
    error = state[:last_error]

    lines =
      if error do
        lines ++ [%{kind: :error, text: format_error(error)}]
      else
        lines
      end

    # Follow-tail while streaming: append live buffer as last assistant line
    lines =
      if state[:streaming] and is_binary(state[:buffer]) and state[:buffer] != "" do
        # Live buffer already had ESC stripped; full sanitize at agent_end
        lines ++ [%{kind: :assistant, text: state[:buffer], streaming: true}]
      else
        lines
      end

    lines
    |> Enum.flat_map(&wrap_entry(&1, width))
    |> Enum.take(-max_lines)
    |> pad_body(max_lines)
  end

  defp pad_body(lines, max) when length(lines) >= max, do: lines
  defp pad_body(lines, max), do: lines ++ List.duplicate("", max - length(lines))

  defp wrap_entry(%{kind: :user, text: t}, width) do
    [Theme.bold("you") <> "  " <> String.slice(to_string(t), 0, width - 6)]
  end

  defp wrap_entry(%{kind: :assistant, text: t, streaming: true}, width) do
    [Theme.accent("arvo") <> " " <> String.slice(to_string(t), 0, width - 6) <> "▍"]
  end

  defp wrap_entry(%{kind: :assistant, text: t}, width) do
    [Theme.accent("arvo") <> " " <> String.slice(to_string(t), 0, width - 5)]
  end

  defp wrap_entry(%{kind: :tool, text: t, name: n, folded: true}, _width) do
    [Theme.muted("  ▸ tool #{n}: #{String.slice(to_string(t), 0, 40)}")]
  end

  defp wrap_entry(%{kind: :tool, text: t, name: n}, _width) do
    [Theme.muted("  ▸ tool #{n}: #{String.slice(to_string(t), 0, 60)}")]
  end

  defp wrap_entry(%{kind: :error, text: t}, width) do
    [Theme.error("! " <> String.slice(to_string(t), 0, width - 2))]
  end

  defp wrap_entry(%{kind: :system, text: t}, width) do
    [Theme.dim(String.slice(to_string(t), 0, width))]
  end

  defp wrap_entry(other, width) when is_binary(other), do: [String.slice(other, 0, width)]
  defp wrap_entry(_, _), do: []

  defp status_label(%{status: :running, tool_name: n}) when is_binary(n), do: "tool:#{n}"
  defp status_label(%{status: :running, spinner: true}), do: "thinking"
  defp status_label(%{status: :running}), do: "running"
  defp status_label(%{status: :idle}), do: "idle"
  defp status_label(_), do: "idle"

  defp format_error(e) when is_binary(e), do: e
  defp format_error(e), do: inspect(e)
end
