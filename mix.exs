defmodule Arvo.MixProject do
  use Mix.Project

  def project do
    [
      app: :arvo,
      version: "0.1.0",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      releases: releases()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl, :crypto],
      mod: {Arvo.Application, []}
    ]
  end

  # KTD-D1: Mix release + ERTS (not Ore-style single static binary).
  # Build on arch matching Harbor task (linux/amd64 unless jobs say otherwise):
  #   MIX_ENV=prod mix release arvo
  # Artifact: _build/prod/arvo-*.tar.gz (or _build/prod/rel/arvo/)
  defp releases do
    [
      arvo: [
        include_executables_for: [:unix],
        include_erts: true,
        applications: [runtime_tools: :permanent],
        steps: [:assemble, :tar],
        overlays: "rel/overlays",
        # Cookie not required for eval/one-shot; set for completeness.
        cookie: "arvo_headless"
      ]
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
      {:termite, "~> 0.4.3"},
      {:rustler, "~> 0.36", runtime: false},
      # Focus transcript: CommonMark → ANSI (MDEx) + Makeup code highlighting
      {:marcli, "~> 0.3.1"},
      {:makeup, "~> 1.2"},
      {:makeup_elixir, "~> 1.0"}
    ]
  end

end
