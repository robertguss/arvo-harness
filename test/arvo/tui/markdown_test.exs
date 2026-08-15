defmodule Arvo.TUI.MarkdownTest do
  use ExUnit.Case, async: true

  alias Arvo.TUI.Markdown

  test "renders bold, headers, lists, and inline code" do
    md = """
    **Arvo** (`coding-agent-harness`) is a harness.

    ### Philosophy
    - Fast, minimal TUI
    - Hackable enough to rewrite weekly
    """

    out = Markdown.render(md)
    plain = Markdown.strip_ansi(out)

    # Markers stripped; content kept
    refute plain =~ "**"
    refute plain =~ "###"
    assert plain =~ "Arvo"
    assert plain =~ "coding-agent-harness"
    assert plain =~ "Philosophy"
    assert plain =~ "Fast, minimal TUI"
    # ANSI present for formatting
    assert out =~ "\e["
  end

  test "syntax-highlights fenced elixir via Makeup" do
    md = """
    ```elixir
    def hello, do: :world
    ```
    """

    out = Markdown.render(md)
    plain = Markdown.strip_ansi(out)

    assert plain =~ "def"
    assert plain =~ "hello"
    assert plain =~ "world"
    # Keyword / name colors differ from plain text
    assert out =~ "\e[35m" or out =~ "\e[33m" or out =~ "\e[36m"
  end

  test "format_lines wraps by visible width not ANSI length" do
    md = String.duplicate("**word** ", 20)
    width = 24
    lines = Markdown.format_lines(md, width)

    assert length(lines) > 1

    for line <- lines do
      assert Markdown.visible_width(line) <= width
    end

    joined = lines |> Enum.map_join(" ", &Markdown.strip_ansi/1)
    assert joined =~ "word"
  end

  test "soft-wraps at spaces; does not split normal words" do
    # Prose that must not become "coding-agent-har" / "ness" mid-token.
    md =
      "Arvo (`coding-agent-harness`) is a personal terminal coding-agent harness " <>
        "written in Elixir/BEAM used daily."

    width = 36
    lines = Markdown.format_lines(md, width)
    plains = Enum.map(lines, &Markdown.strip_ansi/1)

    assert length(plains) > 1

    for line <- plains do
      assert String.length(line) <= width
      # No partial splits of the long hyphenated token across a wrap edge.
      refute line =~ ~r/coding-agent-har$/
      refute line =~ ~r/^ness/
    end

    joined = Enum.join(plains, " ")
    assert joined =~ "coding-agent-harness"
    assert joined =~ "Elixir/BEAM"
  end

  test "hard-breaks unbreakable runs longer than width" do
    token = String.duplicate("x", 50)
    lines = Markdown.wrap_visible(token, 20)
    assert length(lines) >= 3
    assert Enum.all?(lines, &(Markdown.visible_width(&1) <= 20))
    assert Enum.map_join(lines, "", &Markdown.strip_ansi/1) == token
  end

  test "soft-wrap preserves bold across line breaks" do
    # Force wrap inside a bold span (no trailing space before closing **).
    md = "**" <> Enum.map_join(1..12, " ", fn _ -> "boldword" end) <> "**"
    lines = Markdown.format_lines(md, 28)
    assert length(lines) > 1

    # Every content line should reopen bold (SGR 1) after soft-break.
    assert Enum.all?(lines, &String.contains?(&1, "\e[1m"))
    refute Enum.any?(lines, &String.contains?(Markdown.strip_ansi(&1), "**"))
  end

  test "incomplete / streaming markdown does not raise" do
    partial = "**Arvo is still open and a fence:\n```elixir\ndef foo"
    lines = Markdown.format_lines(partial, 40)
    assert is_list(lines)
    assert length(lines) >= 1
    plain = Enum.map_join(lines, "\n", &Markdown.strip_ansi/1)
    assert plain =~ "Arvo" or plain =~ "foo" or plain =~ "def"
  end

  test "assistant frame shows formatted markdown not raw markers" do
    st = %{
      model: "xai:g",
      profile: "base",
      tokens: %{cumulative: 0, window: 100},
      status: :idle,
      transcript: [
        %{
          kind: :assistant,
          text: """
          **Arvo** is a harness.

          ### Layout
          - `arvo/` main app
          - `docs/` plans

          ```elixir
          def hello, do: :ok
          ```
          """
        }
      ],
      buffer: "",
      streaming: false,
      input: "",
      last_error: nil
    }

    frame = Arvo.TUI.Render.frame(st, width: 60, height: 24)
    plain = Markdown.strip_ansi(frame)

    assert plain =~ "Arvo"
    assert plain =~ "Layout"
    assert plain =~ "arvo/"
    assert plain =~ "hello"
    # Raw markdown markers should not dominate the pane
    refute plain =~ "**Arvo**"
    refute plain =~ "### Layout"
  end
end
