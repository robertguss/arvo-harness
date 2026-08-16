# Small fixture for the progressive-attention control eval.
# Agent must rename module SmallBuggy -> SmallFixed (typo fix).
# REQUIRED_FACT_MARKER: PAYLOAD_TOKEN_2b8e4d
defmodule SmallBuggy do
  @moduledoc """
  Greets operators. The module name carries a known typo; everything else in
  this workspace is deliberately tiny.
  """

  @greeting "hello from the small control workspace"

  def hello, do: @greeting

  def hello(name) when is_binary(name) do
    "#{@greeting}, #{name}"
  end

  def shout(name) when is_binary(name) do
    name |> hello() |> String.upcase()
  end
end
