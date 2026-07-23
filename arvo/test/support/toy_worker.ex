defmodule Toy.Worker do
  @moduledoc false
  use GenServer

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, opts)
  def init(_), do: {:ok, %{}}
end
