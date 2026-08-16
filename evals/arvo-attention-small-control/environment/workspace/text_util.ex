defmodule TextUtil do
  @moduledoc "Tiny text helpers; unrelated to the rename task."

  def squish(text) when is_binary(text) do
    text |> String.split() |> Enum.join(" ")
  end

  def word_count(text) when is_binary(text) do
    text |> String.split() |> length()
  end
end
