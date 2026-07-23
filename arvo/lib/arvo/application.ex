defmodule Arvo.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    # Load global + project config before children start (stubs may read Application env later).
    config = Arvo.Config.load(Arvo.cwd())
    Application.put_env(:arvo, :config, config)
    Application.put_env(:arvo, :cwd, Arvo.cwd())

    children = [
      Arvo.Providers.Registry,
      Arvo.Auth.TokenManager,
      Arvo.Plugins.Supervisor,
      Arvo.Plugins.Registry,
      Arvo.Session,
      Arvo.TUI
    ]

    opts = [strategy: :one_for_one, name: Arvo.Supervisor]
    result = Supervisor.start_link(children, opts)

    case result do
      {:ok, _pid} ->
        maybe_start_repl()
        result

      other ->
        other
    end
  end

  defp maybe_start_repl do
    # Interactive line REPL only when launched via the wrapper / mix run (not under test).
    if Application.get_env(:arvo, :start_repl, true) do
      Task.start(fn -> Arvo.Repl.run() end)
    end
  end
end
