defmodule Fff.Plugin do
  @moduledoc """
  Flagship plugin entry. In the monorepo checkout, modules live in the host
  `arvo` app (`lib/fff/*`) so the Rustler NIF (otp_app: :arvo) loads correctly.
  This directory is the canonical plugin layout for external loaders.
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
