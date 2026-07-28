defmodule Arvo.TUI.Render do
  @moduledoc """
  Pure Focus layout projector: ghost strip + transcript + input + footer.
  No model calls — state in, ANSI string out.
  """

  alias Arvo.TUI.Markdown
  alias Arvo.TUI.Theme

  # Visual width of role prefixes ("you  " / "arvo ") — ANSI not counted.
  @role_pad 5
  # Expanded activity/tool detail hard cap.
  @detail_expanded_lines 16
  @palette_max 7

  @doc "Render full screen frame from TUI state map."
  def frame(state, opts \\ []) do
    width = Keyword.get(opts, :width, 80)
    height = Keyword.get(opts, :height, 24)
    scroll = Keyword.get(opts, :scroll, state[:scroll] || 0)

    ghost = ghost_line(state, width)
    footer = footer_line(state, width)
    input = input_line(state, width)
    palette_rows = palette_lines(state, width)

    # Chrome: ghost, blank, body..., [palette...], blank, input, footer
    reserved = 5 + length(palette_rows)
    body_h = max(height - reserved, 1)
    body = transcript_lines(state, body_h, width, scroll)

    rows = [ghost, "" | body] ++ palette_rows ++ ["", input, footer]
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
    base =
      if state[:palette] do
        "↑↓ select · Enter run · Esc close palette"
      else
        "Enter send · Esc cancel · ↑↓ focus · Ctrl+E all · / cmds · PgUp/Dn"
      end

    line =
      case state[:status] do
        :running -> Theme.accent(" running · Esc cancels ") <> Theme.muted(base)
        _ -> Theme.muted(base)
      end

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

    focus_idx = state[:focus_idx]

    all =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {entry, i} ->
        wrap_entry(entry, width, focused?: focus_idx == i)
      end)

    window(all, max_lines, scroll)
  end

  def palette_lines(state, width \\ 80) do
    case state[:palette] do
      %{query: q, selected: sel} ->
        items = Arvo.TUI.SlashMenu.filter(q || "")
        sel = Arvo.TUI.SlashMenu.clamp_selected(items, sel || 0)
        shown = Enum.take(items, @palette_max)

        if shown == [] do
          [Theme.dim("  (no matching commands)")]
        else
          Enum.with_index(shown)
          |> Enum.map(fn {{name, desc}, i} ->
            mark = if i == sel, do: Theme.accent("› "), else: "  "
            name_s = if i == sel, do: Theme.bold("/" <> name), else: "/" <> name
            rest = Theme.muted("  " <> desc)
            line = mark <> name_s <> rest
            # approximate trim
            if String.length(Markdown.strip_ansi(line)) > width do
              String.slice(line, 0, width + 20)
            else
              line
            end
          end)
        end

      _ ->
        []
    end
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

  defp wrap_entry(%{kind: :user, text: t}, width, _opts) do
    wrap_role(Theme.bold("you") <> "  ", String.duplicate(" ", @role_pad), to_string(t), width, false)
  end

  defp wrap_entry(%{kind: :assistant, text: t, streaming: true}, width, _opts) do
    wrap_role_md(Theme.accent("arvo") <> " ", String.duplicate(" ", @role_pad), to_string(t), width, true)
  end

  defp wrap_entry(%{kind: :assistant, text: t}, width, _opts) do
    wrap_role_md(Theme.accent("arvo") <> " ", String.duplicate(" ", @role_pad), to_string(t), width, false)
  end

  defp wrap_entry(%{kind: :thought} = entry, width, opts) do
    focused? = Keyword.get(opts, :focused?, false)
    live? = Map.get(entry, :live, false)
    expanded? = Map.get(entry, :expanded, live?)
    text = Map.get(entry, :text) || ""

    header =
      cond do
        live? -> "◆ Thinking…"
        true -> "◆ Thought for #{thought_duration(entry)}"
      end

    header = if focused?, do: Theme.accent(header), else: Theme.dim(header)

    if expanded? and text != "" do
      body_w = max(width - 2, 1)

      body =
        text
        |> wrap_text(body_w)
        |> Enum.map(&Theme.dim("  " <> &1))

      [header | body]
    else
      [header]
    end
  end

  defp wrap_entry(%{kind: :activity} = entry, width, opts) do
    focused? = Keyword.get(opts, :focused?, false)
    summary = Map.get(entry, :summary) || Map.get(entry, :name) || "tool"
    status = Map.get(entry, :status, :ok)
    expanded? = Map.get(entry, :expanded, false)
    detail = Map.get(entry, :detail)

    {glyph, paint} =
      case status do
        :running -> {"◇ ", &Theme.accent/1}
        :error -> {"✗ ", &Theme.error/1}
        _ -> {"◆ ", &Theme.muted/1}
      end

    line = glyph <> summary
    line = if focused?, do: Theme.bold(paint.(line)), else: paint.(line)

    if expanded? and is_binary(detail) and detail != "" do
      body_w = max(width - 4, 1)
      [line | preview_body(detail, body_w, @detail_expanded_lines)]
    else
      [line]
    end
  end

  # Legacy :tool entries (tests / older sessions) — compact + optional expand
  defp wrap_entry(%{kind: :tool, text: t, name: n} = entry, width, opts) do
    focused? = Keyword.get(opts, :focused?, false)
    expanded? = Map.get(entry, :expanded, not Map.get(entry, :folded, true))
    err? = Map.get(entry, :is_error, false)
    running? = to_string(t) in ["running…", "running...", ""]
    summary = Map.get(entry, :summary) || "tool #{n}"

    {glyph, paint} =
      cond do
        running? -> {"◇ ", &Theme.accent/1}
        err? -> {"✗ ", &Theme.error/1}
        true -> {"◆ ", &Theme.muted/1}
      end

    line = glyph <> summary
    line = if focused?, do: Theme.bold(paint.(line)), else: paint.(line)

    if running? or not expanded? do
      [line]
    else
      body_w = max(width - 4, 1)
      [line | preview_body(to_string(t), body_w, @detail_expanded_lines)]
    end
  end

  defp wrap_entry(%{kind: :error, text: t}, width, _opts) do
    w = max(width - 2, 1)

    t
    |> to_string()
    |> wrap_text(w)
    |> Enum.map(fn line -> Theme.error("! " <> line) end)
  end

  defp wrap_entry(%{kind: :system, text: t}, width, _opts) do
    w = max(width, 1)

    t
    |> to_string()
    |> wrap_text(w)
    |> Enum.map(&Theme.dim/1)
  end

  defp wrap_entry(other, width, _opts) when is_binary(other), do: wrap_text(other, max(width, 1))
  defp wrap_entry(_, _, _), do: []

  defp thought_duration(%{started_at: s, ended_at: e}) when is_integer(s) and is_integer(e) do
    ms = max(e - s, 0)
    if ms < 1000, do: "#{ms}ms", else: "#{Float.round(ms / 1000, 1)}s"
  end

  defp thought_duration(_), do: "…"

  defp wrap_role(first_prefix, cont_prefix, text, width, streaming?) do
    content_w = max(width - @role_pad, 1)
    lines = wrap_text(text, content_w)
    apply_role_prefixes(first_prefix, cont_prefix, lines, streaming?)
  end

  # Assistant path: Marcli markdown → ANSI, then role-pad. Markdown owns wrap width.
  defp wrap_role_md(first_prefix, cont_prefix, text, width, streaming?) do
    content_w = max(width - @role_pad, 1)
    lines = Markdown.format_lines(text, content_w)
    apply_role_prefixes(first_prefix, cont_prefix, lines, streaming?)
  end

  defp apply_role_prefixes(first_prefix, cont_prefix, lines, streaming?) do
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
  # Soft-wrap on word boundaries; preserve explicit newlines (incl. blank lines).
  # Unbreakable runs longer than width still hard-break. No ANSI here — user/tool/system paths.
  def wrap_text(text, width) when is_binary(text) and is_integer(width) and width >= 1 do
    text
    |> String.split("\n")
    |> Enum.flat_map(&chunk_line(&1, width))
  end

  defp chunk_line("", _width), do: [""]

  defp chunk_line(line, width) do
    if String.length(line) <= width do
      [line]
    else
      soft_chunk(line, width)
    end
  end

  defp soft_chunk(line, width) do
    tokens =
      Regex.scan(~r/\s+|\S+/, line)
      |> Enum.map(fn [tok] ->
        if String.match?(tok, ~r/^\s+$/),
          do: {:ws, tok, String.length(tok)},
          else: {:word, tok, String.length(tok)}
      end)

    {row, _vw, out} =
      Enum.reduce(tokens, {"", 0, []}, fn
        {:ws, s, w}, {row, vw, out} ->
          cond do
            vw == 0 -> {row <> s, w, out}
            vw + w <= width -> {row <> s, vw + w, out}
            true -> {"", 0, push_row(row, out)}
          end

        {:word, s, w}, {row, vw, out} ->
          cond do
            vw + w <= width ->
              {row <> s, vw + w, out}

            vw == 0 ->
              place_hard_plain(s, width, out)

            true ->
              place_hard_plain(s, width, push_row(row, out))
          end
      end)

    Enum.reverse(push_row(row, out))
  end

  defp place_hard_plain(s, width, out) do
    if String.length(s) <= width do
      {s, String.length(s), out}
    else
      chunks = hard_chunks_plain(s, width)
      {last, earlier} = List.pop_at(chunks, -1)
      {last, String.length(last), Enum.reduce(earlier, out, fn c, acc -> [c | acc] end)}
    end
  end

  defp push_row(row, out) do
    case String.trim_trailing(row) do
      "" -> out
      r -> [r | out]
    end
  end

  defp hard_chunks_plain(s, width), do: do_hard_chunks_plain(s, width, [])
  defp do_hard_chunks_plain("", _w, acc), do: Enum.reverse(acc)

  defp do_hard_chunks_plain(s, w, acc) do
    {left, right} = String.split_at(s, w)
    do_hard_chunks_plain(right, w, [left | acc])
  end

  defp status_label(%{status: :running, tool_name: n}) when is_binary(n), do: "tool:#{n}"
  defp status_label(%{status: :running, spinner: true}), do: "thinking"
  defp status_label(%{status: :running}), do: "running"
  defp status_label(%{status: :idle}), do: "idle"
  defp status_label(_), do: "idle"

  defp format_error(e) when is_binary(e), do: e
  defp format_error(e), do: inspect(e)
end
