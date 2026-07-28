defmodule Arvo.TUI.Markdown do
  @moduledoc """
  Markdown → ANSI for Focus transcript lines.

  Uses [Marcli](https://hex.pm/packages/marcli) (MDEx parser + optional Makeup
  syntax highlighting). Owns visible-width wrapping so role padding and frame
  height stay correct despite embedded SGR sequences.

  Wrapping prefers word boundaries (spaces); only hard-breaks runs longer than
  the pane width (URLs, long paths, unbroken tokens). Open styles are closed at
  each soft-break and reopened on the next row so bold/code spans survive wrap.
  """

  @csi_re ~r/\e\[[0-9;]*m/

  @doc """
  Render markdown and soft-wrap to `width` visible columns.

  Returns a list of ANSI strings (one per display row). On parse/render failure,
  falls back to plain soft-wrap of the raw source (no crash mid-stream).
  """
  @spec format_lines(String.t(), pos_integer()) :: [String.t()]
  def format_lines(text, width) when is_binary(text) and is_integer(width) and width >= 1 do
    text
    |> render()
    |> wrap_visible(width)
  rescue
    _ -> plain_wrap(text, width)
  end

  @doc "Render markdown to a single ANSI string (no width wrap)."
  @spec render(String.t()) :: String.t()
  def render(text) when is_binary(text) do
    ensure_highlighters()
    Marcli.render(text, theme: theme())
  end

  @doc "Strip CSI SGR sequences (visible-width / tests)."
  @spec strip_ansi(String.t()) :: String.t()
  def strip_ansi(text) when is_binary(text), do: String.replace(text, @csi_re, "")

  @doc "Visible column width ignoring CSI SGR sequences."
  @spec visible_width(String.t()) :: non_neg_integer()
  def visible_width(text) when is_binary(text), do: text |> strip_ansi() |> String.length()

  # Align with Arvo Focus accent (cyan) rather than Marcli's yellow h1.
  defp theme do
    Marcli.Theme.merge(
      h1: "\e[1;36m",
      h2: "\e[1;36m",
      h3: "\e[1;37m",
      inline_code: "\e[36m",
      code_top: "  ┌─",
      code_left: "  │ ",
      code_bottom: "  └─",
      bullet_marker: "  ▸ ",
      thematic_break_width: 32
    )
  end

  defp ensure_highlighters do
    _ = Application.ensure_all_started(:makeup)
    _ = Application.ensure_all_started(:makeup_elixir)
    :ok
  end

  # -- wrap (ANSI-safe, soft at spaces) --------------------------------------

  @doc false
  def wrap_visible(text, width) when is_binary(text) and width >= 1 do
    text
    |> String.split("\n")
    |> Enum.flat_map(&wrap_one_line(&1, width))
  end

  defp wrap_one_line("", _width), do: [""]

  defp wrap_one_line(line, width) do
    if visible_width(line) <= width do
      [line]
    else
      line
      |> tokenize()
      |> pack(width)
    end
  end

  # Tokens: {:sgr, seq} | {:ws, text, vw} | {:word, text, vw}
  # SGR is its own token so open styles survive soft-breaks mid-phrase.
  defp tokenize(line), do: do_tokenize(line, nil, [])

  # mode: nil | {:ws, acc, vw} | {:word, acc, vw}
  defp do_tokenize("", nil, acc), do: Enum.reverse(acc)
  defp do_tokenize("", {:ws, a, w}, acc), do: Enum.reverse([{:ws, IO.iodata_to_binary(a), w} | acc])

  defp do_tokenize("", {:word, a, w}, acc),
    do: Enum.reverse([{:word, IO.iodata_to_binary(a), w} | acc])

  defp do_tokenize(bin, mode, acc) do
    case next_atom(bin) do
      :done ->
        do_tokenize("", mode, acc)

      {:sgr, seq, rest} ->
        # Flush any open word/ws before a style change so SGR sits between tokens.
        acc2 = flush_mode(mode, acc)
        do_tokenize(rest, nil, [{:sgr, seq} | acc2])

      {:char, ch, rest} ->
        {mode2, acc2} = absorb_char(mode, ch, acc)
        do_tokenize(rest, mode2, acc2)
    end
  end

  defp flush_mode(nil, acc), do: acc

  defp flush_mode({:ws, a, w}, acc), do: [{:ws, IO.iodata_to_binary(a), w} | acc]
  defp flush_mode({:word, a, w}, acc), do: [{:word, IO.iodata_to_binary(a), w} | acc]

  defp next_atom(<<>>), do: :done

  defp next_atom(<<"\e[", rest::binary>>) do
    case Regex.run(~r/^([0-9;]*m)(.*)/s, rest) do
      [_, body, tail] ->
        {:sgr, "\e[" <> body, tail}

      _ ->
        {ch, tail} = String.next_grapheme(<<"\e[", rest::binary>>)
        {:char, ch, tail}
    end
  end

  defp next_atom(bin) do
    {ch, rest} = String.next_grapheme(bin)
    {:char, ch, rest}
  end

  defp absorb_char(nil, ch, acc) do
    if whitespace?(ch), do: {{:ws, [ch], 1}, acc}, else: {{:word, [ch], 1}, acc}
  end

  defp absorb_char({:ws, a, w}, ch, acc) do
    if whitespace?(ch) do
      {{:ws, [a, ch], w + 1}, acc}
    else
      {{:word, [ch], 1}, [{:ws, IO.iodata_to_binary(a), w} | acc]}
    end
  end

  defp absorb_char({:word, a, w}, ch, acc) do
    if whitespace?(ch) do
      {{:ws, [ch], 1}, [{:word, IO.iodata_to_binary(a), w} | acc]}
    else
      {{:word, [a, ch], w + 1}, acc}
    end
  end

  defp whitespace?(ch), do: ch == " " or ch == "\t"

  # Pack tokens into display rows.
  # State: row iodata, row visible width, open SGR stack, out lines (reversed).
  defp pack(tokens, width) do
    {row, _vw, open, out} =
      Enum.reduce(tokens, {[], 0, [], []}, fn tok, {row, vw, open, out} ->
        pack_token(tok, width, row, vw, open, out)
      end)

    case finish_row(row, open) do
      nil -> Enum.reverse(out)
      line -> Enum.reverse([line | out])
    end
  end

  defp pack_token({:sgr, seq}, _width, row, vw, open, out) do
    open2 = if seq == "\e[0m", do: [], else: open ++ [seq]
    {[row, seq], vw, open2, out}
  end

  defp pack_token({:ws, text, w}, width, row, vw, open, out) do
    cond do
      # Keep leading indent (list markers, code gutters).
      vw == 0 ->
        {[row, text], w, open, out}

      vw + w <= width ->
        {[row, text], vw + w, open, out}

      true ->
        # Soft-break before this space; drop the overflowing spaces.
        case finish_row(row, open) do
          nil -> {reopen_iodata(open), 0, open, out}
          line -> {reopen_iodata(open), 0, open, [line | out]}
        end
    end
  end

  defp pack_token({:word, text, w}, width, row, vw, open, out) do
    cond do
      vw + w <= width ->
        {[row, text], vw + w, open, out}

      # Empty row: hard-break an unbreakable run.
      vw == 0 ->
        hard_break_word(text, width, open, out)

      true ->
        # Soft-break before this word, then place it (maybe hard-break).
        out2 =
          case finish_row(row, open) do
            nil -> out
            line -> [line | out]
          end

        pack_token({:word, text, w}, width, reopen_iodata(open), 0, open, out2)
    end
  end

  defp hard_break_word(text, width, open, out) do
    hard_walk(text, width, reopen_iodata(open), 0, open, out)
  end

  defp hard_walk("", _width, row, vw, open, out), do: {row, vw, open, out}

  defp hard_walk(rest, width, row, vw, open, out) do
    case String.next_grapheme(rest) do
      nil ->
        {row, vw, open, out}

      {ch, tail} ->
        if vw + 1 > width and vw > 0 do
          line = finish_row!(row, open)
          hard_walk(rest, width, reopen_iodata(open), 0, open, [line | out])
        else
          hard_walk(tail, width, [row, ch], vw + 1, open, out)
        end
    end
  end

  defp reopen_iodata([]), do: []
  defp reopen_iodata(open), do: open

  defp finish_row(row, open) do
    case IO.iodata_to_binary(row) do
      "" ->
        nil

      bin ->
        trimmed = trim_trailing_spaces(bin)

        if strip_ansi(trimmed) == "" do
          nil
        else
          if open == [], do: trimmed, else: trimmed <> "\e[0m"
        end
    end
  end

  defp finish_row!(row, open) do
    finish_row(row, open) || IO.iodata_to_binary(row)
  end

  defp trim_trailing_spaces(bin) do
    plain = strip_ansi(bin)
    trimmed_plain = String.trim_trailing(plain, " ")

    if trimmed_plain == plain do
      bin
    else
      take_visible(bin, String.length(trimmed_plain), [])
    end
  end

  defp take_visible(_rest, 0, acc), do: acc |> Enum.reverse() |> IO.iodata_to_binary()
  defp take_visible("", _n, acc), do: acc |> Enum.reverse() |> IO.iodata_to_binary()

  defp take_visible(rest, n, acc) when n > 0 do
    case next_atom(rest) do
      :done ->
        acc |> Enum.reverse() |> IO.iodata_to_binary()

      {:sgr, seq, tail} ->
        take_visible(tail, n, [seq | acc])

      {:char, ch, tail} ->
        take_visible(tail, n - 1, [ch | acc])
    end
  end

  # -- plain fallback (no ANSI) ----------------------------------------------

  defp plain_wrap(text, width) do
    text
    |> String.split("\n")
    |> Enum.flat_map(fn
      "" -> [""]
      line -> soft_chunk_plain(line, width)
    end)
  end

  defp soft_chunk_plain(line, width) do
    if String.length(line) <= width do
      [line]
    else
      line
      |> plain_tokens()
      |> pack_plain(width)
    end
  end

  defp plain_tokens(line) do
    Regex.scan(~r/\s+|\S+/, line)
    |> Enum.map(fn [tok] ->
      if String.match?(tok, ~r/^\s+$/) do
        {:ws, tok, String.length(tok)}
      else
        {:word, tok, String.length(tok)}
      end
    end)
  end

  defp pack_plain(tokens, width) do
    {row, _vw, out} =
      Enum.reduce(tokens, {"", 0, []}, fn
        {:ws, s, w}, {row, vw, out} ->
          cond do
            vw == 0 -> {row <> s, w, out}
            vw + w <= width -> {row <> s, vw + w, out}
            true -> {"", 0, maybe_push_row(row, out)}
          end

        {:word, s, w}, {row, vw, out} ->
          cond do
            vw + w <= width ->
              {row <> s, vw + w, out}

            vw == 0 ->
              place_hard(s, width, out)

            true ->
              out2 = maybe_push_row(row, out)
              place_hard(s, width, out2)
          end
      end)

    Enum.reverse(maybe_push_row(row, out))
  end

  defp place_hard(s, width, out) do
    if String.length(s) <= width do
      {s, String.length(s), out}
    else
      chunks = hard_chunks(s, width)
      {last, earlier} = List.pop_at(chunks, -1)
      # earlier is in order; push onto reversed out
      {last, String.length(last), Enum.reduce(earlier, out, fn c, acc -> [c | acc] end)}
    end
  end

  defp maybe_push_row(row, out) do
    case String.trim_trailing(row) do
      "" -> out
      r -> [r | out]
    end
  end

  defp hard_chunks(s, width), do: do_hard_chunks(s, width, [])
  defp do_hard_chunks("", _width, acc), do: Enum.reverse(acc)

  defp do_hard_chunks(s, width, acc) do
    {left, right} = String.split_at(s, width)
    do_hard_chunks(right, width, [left | acc])
  end
end
