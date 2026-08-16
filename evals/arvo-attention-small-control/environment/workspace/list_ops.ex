defmodule ListOps do
  @moduledoc "Tiny list helpers; unrelated to the rename task."

  def middle(list) when is_list(list) do
    Enum.at(list, div(length(list), 2))
  end

  def pairs(list) when is_list(list) do
    Enum.chunk_every(list, 2, 1, :discard)
  end
end
