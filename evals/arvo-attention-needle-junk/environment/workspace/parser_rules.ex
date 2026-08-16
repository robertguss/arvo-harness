# Small fixture for the progressive-attention needle-junk eval.
# Agent must rename module ParserBuggy -> ParserFixed (typo fix).
# REQUIRED_FACT_MARKER: PAYLOAD_TOKEN_9d4e2f
defmodule ParserBuggy do
  @moduledoc """
  Parses operator command strings. The module name carries a known typo; the
  three archive files beside this one are deliberately oversized and correct.
  """

  @sep " "

  def parse(line) when is_binary(line) do
    line |> String.trim() |> String.split(@sep, trim: true)
  end

  def command([head | _rest]), do: head
  def command([]), do: nil
end
