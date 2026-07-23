defmodule Arvo.MixProject do
  use Mix.Project

  def project do
    [
      app: :arvo,
      version: "0.1.0",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Arvo.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:toml, "~> 0.7"},
      {:jido_action, "~> 2.3"},
      {:req, "~> 0.5"},
      {:req_llm, "~> 1.17"},
      {:rustler, "~> 0.36", runtime: false}
    ]
  end
end
