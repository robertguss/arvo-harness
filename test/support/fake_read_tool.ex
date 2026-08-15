defmodule Arvo.TestSupport.FakeReadTool do
  @moduledoc false
  use Jido.Action,
    name: "read",
    description: "fake read for product path tests",
    schema: [
      path: [type: :string, required: false, default: "x"]
    ]

  def spec, do: Arvo.Tool.spec_from_jido(__MODULE__)

  def run(_params, _ctx), do: {:ok, "ok"}
end

defmodule Arvo.TestSupport.SlowReadTool do
  @moduledoc false
  use Jido.Action,
    name: "read",
    description: "slow fake read",
    schema: [
      path: [type: :string, required: false, default: "x"]
    ]

  def spec, do: Arvo.Tool.spec_from_jido(__MODULE__)

  def run(_params, _ctx) do
    Process.sleep(10_000)
    {:ok, "ok"}
  end
end

