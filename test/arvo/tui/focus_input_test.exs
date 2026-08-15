defmodule Arvo.TUI.FocusInputTest do
  @moduledoc """
  Paste / Enter input path for Focus raw mode.

  Regression: multi-line paste must not treat embedded newlines as submit.
  """
  use ExUnit.Case, async: true

  alias Arvo.TUI.Focus
  alias Arvo.TUI.Render

  defp local(overrides \\ %{}) do
    Map.merge(%{input: "", paste: false, pending: "", scroll: 0, palette: nil}, overrides)
  end

  defp idle, do: %{status: :idle, tree: nil}

  test "bulk multi-line chunk inserts without submitting" do
    assert {:cont, loc} =
             Focus.apply_keys(
               "Run this once:\n\npython3 -c \"print(1)\"",
               local(),
               idle()
             )

    assert loc.input == "Run this once:\n\npython3 -c \"print(1)\""
    assert loc.paste == false
  end

  test "bracketed paste: newlines during paste insert; end leaves draft intact" do
    st = idle()

    assert {:cont, loc} = Focus.apply_keys("\e[200~", local(), st)
    assert loc.paste == true
    assert loc.input == ""

    assert {:cont, loc} = Focus.apply_keys("line1\n", loc, st)
    assert loc.paste == true
    assert loc.input == "line1\n"

    assert {:cont, loc} = Focus.apply_keys("line2", loc, st)
    assert loc.input == "line1\nline2"

    assert {:cont, loc} = Focus.apply_keys("\e[201~", loc, st)
    assert loc.paste == false
    assert loc.input == "line1\nline2"
  end

  test "bracketed paste markers and body in one chunk" do
    chunk = "\e[200~hello\nworld\e[201~"

    assert {:cont, loc} = Focus.apply_keys(chunk, local(), idle())
    assert loc.paste == false
    assert loc.input == "hello\nworld"
  end

  test "line-by-line paste under bracketed mode does not submit on lone newline" do
    st = idle()
    {:cont, loc} = Focus.apply_keys("\e[200~", local(), st)
    {:cont, loc} = Focus.apply_keys("first", loc, st)
    {:cont, loc} = Focus.apply_keys("\n", loc, st)
    {:cont, loc} = Focus.apply_keys("second", loc, st)
    {:cont, loc} = Focus.apply_keys("\e[201~", loc, st)

    assert loc.input == "first\nsecond"
    assert loc.paste == false
  end

  test "CRLF bulk paste normalizes to newlines without submit" do
    assert {:cont, loc} = Focus.apply_keys("a\r\nb\r\nc", local(), idle())
    assert loc.input == "a\nb\nc"
  end

  test "incomplete paste start is held in pending across chunks" do
    st = idle()
    assert {:cont, loc} = Focus.apply_keys("\e[200", local(), st)
    assert loc.pending == "\e[200"
    assert loc.input == ""

    assert {:cont, loc} = Focus.apply_keys("~hi\e[201~", loc, st)
    assert loc.pending == ""
    assert loc.paste == false
    assert loc.input == "hi"
  end

  test "input_lines soft-wraps multi-line paste across rows" do
    rows = Render.input_lines(%{input: "a\nb\nc", status: :idle}, 80, 12)
    assert length(rows) == 3
    assert Enum.at(rows, 0) =~ "a"
    assert Enum.at(rows, 1) =~ "b"
    assert Enum.at(rows, 2) =~ "c"
    # Continuation rows are indented (no second prompt glyph).
    assert Enum.at(rows, 1) =~ ~r/^  /
  end

  test "input_lines wraps long single line to width" do
    long = String.duplicate("word ", 40)
    rows = Render.input_lines(%{input: long, status: :idle}, 40, 12)
    assert length(rows) > 1
    # No row should exceed terminal width (ANSI-free continuation rows plain).
    plain_lens =
      rows
      |> Enum.map(fn r -> r |> String.replace(~r/\e\[[0-9;]*m/, "") |> String.length() end)

    assert Enum.all?(plain_lens, &(&1 <= 40))
  end

  test "input_lines caps height with overflow cue" do
    draft = Enum.map_join(1..20, "\n", &"line#{&1}")
    rows = Render.input_lines(%{input: draft, status: :idle}, 80, 4)
    assert length(rows) == 4
    assert List.last(rows) =~ "more lines"
    assert Enum.at(rows, 0) =~ "line1"
  end

  test "frame includes wrapped composer without truncating short multi-line draft" do
    state = %{
      status: :idle,
      model: "xai:test",
      profile: "base",
      tokens: %{cumulative: 0, window: 100},
      transcript: [],
      streaming: false,
      buffer: "",
      input: "first line\nsecond line of the paste"
    }

    frame = Render.frame(state, width: 60, height: 24)
    assert frame =~ "first line"
    assert frame =~ "second line of the paste"
  end

  test "printable typing still appends" do
    assert {:cont, loc} = Focus.apply_keys("hello", local(), idle())
    assert loc.input == "hello"
    assert {:cont, loc} = Focus.apply_keys("!", loc, idle())
    assert loc.input == "hello!"
  end

  test "backspace deletes one grapheme from draft" do
    assert {:cont, loc} = Focus.apply_keys("ab", local(), idle())
    assert {:cont, loc} = Focus.apply_keys("\x7f", loc, idle())
    assert loc.input == "a"
  end
end
