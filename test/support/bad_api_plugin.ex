defmodule BadApi.Plugin do
  def manifest do
    %{api: 99, tools: [], skills: [], children: [], commands: [], hooks: []}
  end

  def activate(_), do: :ok
  def deactivate(_), do: :ok
end
