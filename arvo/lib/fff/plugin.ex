defmodule Fff.Plugin do
  @moduledoc """
  Flagship search plugin (SPEC milestone 7). Standard Arvo.Plugin; search via Rustler NIF.
  """

  @behaviour Arvo.Plugin

  def manifest do
    %{
      api: 1,
      tools: [Fff.SearchTool],
      skills: [],
      children: [],
      commands: [],
      hooks: []
    }
  end

  def activate(_ctx) do
    _ = Code.ensure_loaded(Fff.Native)
    :ok
  end

  def deactivate(_ctx), do: :ok
end
