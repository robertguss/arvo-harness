defmodule Toy.Plugin do
  @moduledoc false
  @behaviour Arvo.Plugin

  def manifest do
    %{
      api: 1,
      tools: [Toy.EchoTool],
      skills: [],
      children: [{Toy.Worker, []}],
      commands: [],
      hooks: []
    }
  end

  def activate(_ctx), do: :ok
  def deactivate(_ctx), do: :ok
end
