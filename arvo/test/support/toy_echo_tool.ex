defmodule Toy.EchoTool do
  @moduledoc false

  use Jido.Action,
    name: "toy_echo",
    description: "Echo a string (toy plugin tool)",
    schema: [
      text: [type: :string, required: true, doc: "Text to echo"]
    ]

  def spec, do: Arvo.Tool.spec_from_jido(__MODULE__)

  @impl Jido.Action
  def run(params, _ctx) do
    text = params[:text] || params["text"] || ""
    {:ok, "toy says: #{text}"}
  end
end
