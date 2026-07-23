defmodule Fff.MixProject do
  use Mix.Project

  def project do
    [
      app: :fff,
      version: "0.1.0",
      elixir: "~> 1.20",
      deps: [{:jido_action, "~> 2.3"}]
    ]
  end

  def application do
    [extra_applications: []]
  end
end
