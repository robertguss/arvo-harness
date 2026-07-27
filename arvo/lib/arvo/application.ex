defmodule Arvo.Application do
  @moduledoc false
  use Application

  require Logger

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
        # After Registry+TUI are up: apply project profile plugins (SPEC §5).
        _ = maybe_auto_activate_profile()
        maybe_start_interactive()
        result

      other ->
        other
    end
  end

  @doc """
  Apply `profile` from project config via `Arvo.Profiles.auto_activate_project/2`.

  Safe to call after the supervision tree is running (e.g. tests). Failures are
  logged and returned; boot continues.
  """
  def maybe_auto_activate_profile(cwd \\ nil) do
    cwd = cwd || Application.get_env(:arvo, :cwd) || Arvo.cwd()

    case Arvo.Profiles.auto_activate_project(cwd) do
      {:ok, _} = ok ->
        ok

      {:error, reason} = err ->
        Logger.warning(
          "Arvo: project profile auto-activate failed for #{cwd}: #{inspect(reason)}"
        )

        err
    end
  end

  defp maybe_start_interactive do
    # Product default: Focus owns the terminal (not Repl). Repl remains library/fallback.
    # Under test, both stay off unless explicitly enabled.
    _ = maybe_auto_resume()

    cond do
      Application.get_env(:arvo, :start_focus, true) and not Application.get_env(:arvo, :start_repl, false) ->
        # Focus.run/0 stops the VM on quit when :halt_on_focus_quit is true (default).
        Task.start(fn -> Arvo.TUI.Focus.run() end)

      Application.get_env(:arvo, :start_repl, false) ->
        Task.start(fn -> Arvo.Repl.run() end)

      true ->
        :ok
    end
  end

  @doc """
  Same-cwd auto-resume last resumable session by HEAD (R14).
  Skips empty shells via `list_resumable_for_cwd`. No-op when none.
  """
  def maybe_auto_resume(cwd \\ nil) do
    if Application.get_env(:arvo, :auto_resume, true) do
      cwd = cwd || Application.get_env(:arvo, :cwd) || Arvo.cwd()

      case Arvo.Session.Store.list_resumable_for_cwd(cwd) do
        [path | _] ->
          case Arvo.Session.resume(path) do
            {:ok, resumed} = ok ->
              reapply_profile_from_resume(resumed)
              ok

            other ->
              Logger.warning(
                "Arvo: same-cwd auto-resume failed for #{path}: #{inspect(other)}"
              )

              other
          end

        [] ->
          :noop
      end
    else
      :noop
    end
  end

  # R13/AE2: session meta.profile is a name only; re-run Profiles.switch so tools/skills match.
  defp reapply_profile_from_resume(resumed) do
    case resumed[:profile] || resumed["profile"] do
      p when is_binary(p) and p != "" ->
        Arvo.Profiles.reapply(p)

      _ ->
        :ok
    end
  end
end


