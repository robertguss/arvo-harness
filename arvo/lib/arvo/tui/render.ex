defmodule Arvo.TUI.Render do
  @moduledoc """
  Pure Focus layout projector: ghost strip + transcript + input + footer.
  No model calls — state in, ANSI string out.
  """

  alias Arvo.TUI.Theme

  # Visual width of role prefixes ("you  " / "arvo ") — ANSI not counted.
  @role_pad 5
  # Folded tool body: enough lines to see what ran without flooding the pane.
  @tool_preview_lines 10
  # Expanded tool body hard cap (viewport still tails/scrolls).
  @tool_expanded_lines 40

  @doc "Render full screen frame from TUI state map."
  def frame(state, opts \\ []) do
    width = Keyword.get(opts, :width, 80)
    height = Keyword.get(opts, :height, 24)
    scroll = Keyword.get(opts, :scroll, state[:scroll] || 0)

    ghost = ghost_line(state, width)
    footer = footer_line(state, width)
    input = input_line(state, width)

    # Fixed chrome rows: ghost, blank, (body...), blank, input, footer → 5 non-body.
    reserved = 5
    body_h = max(height - reserved, 1)
    body = transcript_lines(state, body_h, width, scroll)

    # Exactly `height` rows so overwrite paints (no clear_screen) leave no ghosts.
    rows = [ghost, "" | body] ++ ["", input, footer]
    rows = Enum.take(rows ++ List.duplicate("", height), height)
    Enum.join(rows, "\n")
  end

  def ghost_line(state, width \\ 80) do
    model = state[:model] || "xai:?"
    profile = state[:profile] || "base"
    tokens = state[:tokens] || %{cumulative: 0, window: 500_000}
    cum = tokens[:cumulative] || 0
    win = tokens[:window] || 500_000
    status = status_label(state)

    line = " #{model} · #{profile} · ctx #{cum}/#{win} · #{status}"
    Theme.dim(String.slice(line, 0, max(width, 1)))
  end

  def footer_line(state, width \\ 80) do
    base = "Enter send · Ctrl+J newline · Esc cancel · / slash · PgUp/PgDn scroll"

    line =
      case state[:status] do
        :running -> Theme.accent(" running · Esc cancels ") <> Theme.muted(base)
        _ -> Theme.muted(base)
      end

    # Visible-width truncate is approximate (ANSI); still prevents mid-word wrap
    # on narrow panes when the bare text already exceeds width.
    if String.length(base) > width do
      Theme.muted(String.slice(base, 0, max(width, 1)))
    else
      line
    end
  end

  def input_line(state, width \\ 80) do
    draft = state[:input] || ""
    prefix = if state[:status] == :running, do: "… ", else: "› "
    Theme.bold(prefix) <> String.slice(draft, 0, max(width - 2, 10))
  end

  def transcript_lines(state, max_lines, width, scroll \\ 0) do
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

    all =
      lines
      |> Enum.flat_map(&wrap_entry(&1, width))

    window(all, max_lines, scroll)
  end

  defp window(lines, max_lines, scroll) when scroll <= 0 do
    lines
    |> Enum.take(-max_lines)
    |> pad_body(max_lines)
  end

  defp window(lines, max_lines, scroll) do
    total = length(lines)
    # scroll = how many lines above the live tail are hidden below the viewport.
    # Clamp so we never scroll past the top of history.
    max_scroll = max(total - max_lines, 0)
    scroll = min(scroll, max_scroll)
    end_exclusive = total - scroll
    start = max(end_exclusive - max_lines, 0)

    lines
    |> Enum.slice(start, max_lines)
    |> pad_body(max_lines)
  end

  defp pad_body(lines, max) when length(lines) >= max, do: Enum.take(lines, max)
  defp pad_body(lines, max), do: lines ++ List.duplicate("", max - length(lines))

  defp wrap_entry(%{kind: :user, text: t}, width) do
    wrap_role(Theme.bold("you") <> "  ", String.duplicate(" ", @role_pad), to_string(t), width, false)
  end

  defp wrap_entry(%{kind: :assistant, text: t, streaming: true}, width) do
    wrap_role(Theme.accent("arvo") <> " ", String.duplicate(" ", @role_pad), to_string(t), width, true)
  end

  defp wrap_entry(%{kind: :assistant, text: t}, width) do
    wrap_role(Theme.accent("arvo") <> " ", String.duplicate(" ", @role_pad), to_string(t), width, false)
  end

  defp wrap_entry(%{kind: :tool, text: t, name: n} = entry, width) do
    folded? = Map.get(entry, :folded, true)
    err? = Map.get(entry, :is_error, false)
    running? = to_string(t) in ["running…", "running...", ""]

    status =
      cond do
        running? -> " · running…"
        err? -> " · error"
        true -> ""
      end

    header = Theme.muted("  ▸ tool #{n}#{status}")

    if running? do
      [header]
    else
      body_w = max(width - 4, 1)
      cap = if folded?, do: @tool_preview_lines, else: @tool_expanded_lines
      body = preview_body(to_string(t), body_w, cap)
      [header | body]
    end
  end

  defp wrap_entry(%{kind: :error, text: t}, width) do
    w = max(width - 2, 1)

    t
    |> to_string()
    |> wrap_text(w)
    |> Enum.map(fn line -> Theme.error("! " <> line) end)
  end

  defp wrap_entry(%{kind: :system, text: t}, width) do
    w = max(width, 1)

    t
    |> to_string()
    |> wrap_text(w)
    |> Enum.map(&Theme.dim/1)
  end

  defp wrap_entry(other, width) when is_binary(other), do: wrap_text(other, max(width, 1))
  defp wrap_entry(_, _), do: []

  defp wrap_role(first_prefix, cont_prefix, text, width, streaming?) do
    content_w = max(width - @role_pad, 1)
    lines = wrap_text(text, content_w)
    lines = if lines == [], do: [""], else: lines
    last_i = length(lines) - 1

    Enum.with_index(lines, fn line, i ->
      pref = if i == 0, do: first_prefix, else: cont_prefix
      suffix = if streaming? and i == last_i, do: "▍", else: ""
      pref <> line <> suffix
    end)
  end

  defp preview_body(text, width, cap) do
    wrapped = wrap_text(String.trim_trailing(text), width)
    shown = Enum.take(wrapped, cap)
    more? = length(wrapped) > cap

    body =
      Enum.map(shown, fn line ->
        Theme.muted("    " <> line)
      end)

    if more? do
      body ++ [Theme.dim("    … (#{length(wrapped) - cap} more lines)")]
    else
      body
    end
  end

  @doc false
  # Hard-wrap on grapheme boundaries; preserve explicit newlines (incl. blank lines).
  def wrap_text(text, width) when is_binary(text) and is_integer(width) and width >= 1 do
    text
    |> String.split("\n")
    |> Enum.flat_map(&chunk_line(&1, width))
  end

  defp chunk_line(line, width) do
    if line == "" do
      [""]
    else
      do_chunk(line, width, [])
    end
  end

  defp do_chunk("", _width, acc), do: Enum.reverse(acc)

  defp do_chunk(line, width, acc) do
    {left, right} = String.split_at(line, width)
    do_chunk(right, width, [left | acc])
  end

  defp status_label(%{status: :running, tool_name: n}) when is_binary(n), do: "tool:#{n}"
  defp status_label(%{status: :running, spinner: true}), do: "thinking"
  defp status_label(%{status: :running}), do: "running"
  defp status_label(%{status: :idle}), do: "idle"
  defp status_label(_), do: "idle"

  defp format_error(e) when is_binary(e), do: e
  defp format_error(e), do: inspect(e)
end
