defmodule Toy.Plugin do
  @moduledoc false
  @behaviour Arvo.Plugin

  def manifest do
    %{
      api: 1,
      tools: [Toy.EchoTool],
      skills: [
        %{
          name: "toy-skill",
          description: "A progressive toy skill (name+desc only)",
          path: "/tmp/toy-skill/SKILL.md"
        }
      ],
      children: [{Toy.Worker, []}],
      commands: [
        {"ping", fn _args -> :pong end}
      ],
      hooks: []
    }
  end

  def activate(_ctx), do: :ok
  def deactivate(_ctx), do: :ok
end
