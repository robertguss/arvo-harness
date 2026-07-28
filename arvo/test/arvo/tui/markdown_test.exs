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
