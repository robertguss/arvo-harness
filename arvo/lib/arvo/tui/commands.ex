defmodule Arvo.TUI.Commands do
  @moduledoc "Parse slash command lines into `{name, args}`."

  def parse(line) when is_binary(line) do
    line = String.trim(line)

    if String.starts_with?(line, "/") do
      case String.split(line, " ", parts: 2) do
        ["/" <> cmd] -> {:command, cmd, ""}
        ["/" <> cmd, args] -> {:command, cmd, args}
      end
    else
      {:text, line}
    end
  end
end
