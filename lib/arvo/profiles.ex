defmodule Arvo.Profiles do
  @moduledoc """
  Named plugin bundles in `~/.arvo/profiles/<name>.toml` (SPEC §5).
  base always active; exactly one workflow profile on top.
  """

  def profiles_dir do
    Path.join([System.get_env("HOME") || System.user_home!(), ".arvo", "profiles"])
  end

  def list do
    dir = profiles_dir()

    files =
      case File.ls(dir) do
        {:ok, fs} -> Enum.filter(fs, &String.ends_with?(&1, ".toml"))
        _ -> []
      end

    names = Enum.map(files, &String.trim_trailing(&1, ".toml"))
    Enum.uniq(["base" | names])
  end

  def load(name) when is_binary(name) do
    if name == "base" do
      {:ok, %{name: "base", plugins: []}}
    else
      path = Path.join(profiles_dir(), name <> ".toml")

      case File.read(path) do
        {:ok, body} ->
          case Toml.decode(body) do
            {:ok, map} ->
              plugins = map["plugins"] || map[:plugins] || []
              plugins = if is_list(plugins), do: plugins, else: []
              {:ok, %{name: name, plugins: plugins, raw: map}}

            {:error, reason} ->
              {:error, reason}
          end

        {:error, :enoent} ->
          {:error, :not_found}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  @doc """
  Re-apply a profile by name using the current Registry active set.

  Used by auto-resume and TUI resume rehydrate. Failures are logged, not raised.
  """
  def reapply(name) when is_binary(name) and name != "" do
    active = Arvo.Plugins.Registry.list_active()

    case switch(name, active) do
      {:ok, _} = ok ->
        Application.put_env(:arvo, :active_profile, name)
        ok

      {:error, reason} = err ->
        require Logger
        Logger.warning("Arvo: profile reapply failed for #{name}: #{inspect(reason)}")
        err
    end
  rescue
    e ->
      require Logger
      Logger.warning("Arvo: profile reapply crashed for #{name}: #{Exception.message(e)}")
      {:error, Exception.message(e)}
  end

  @doc """
  Switch workflow profile via set-diff against currently active (non-base) plugins.
  `activate_fun` / `deactivate_fun` receive plugin names and must return `:ok` or `{:error, reason}`.
  Returns `{:ok, %{added, removed, active}}` with **actual** active set, or `{:error, reason}`.
  """
  def switch(new_profile, current_active, opts \\ []) do
    activate_fun = Keyword.get(opts, :activate, &Arvo.Plugins.Registry.activate/1)
    deactivate_fun = Keyword.get(opts, :deactivate, &Arvo.Plugins.Registry.deactivate/1)

    with {:ok, profile} <- load(new_profile) do
      desired = MapSet.new(profile.plugins)

      current =
        current_active
        |> Enum.reject(&(&1 == "base"))
        |> MapSet.new()

      removed = MapSet.difference(current, desired) |> MapSet.to_list()
      added = MapSet.difference(desired, current) |> MapSet.to_list()

      with :ok <- apply_each(removed, deactivate_fun, :deactivate),
           :ok <- apply_each(added, activate_fun, :activate) do
        _ = Arvo.Plugins.Registry.set_profile(new_profile)
        actual = Arvo.Plugins.Registry.list_active()

        {:ok,
         %{
           added: added,
           removed: removed,
           active: actual
         }}
      end
    end
  end

  defp apply_each(names, fun, op) do
    Enum.reduce_while(names, :ok, fn name, :ok ->
      case fun.(name) do
        :ok ->
          {:cont, :ok}

        {:error, reason} ->
          {:halt, {:error, {op, name, reason}}}

        other ->
          # Test stubs often return :ets.insert truthy or ignore return value.
          if other == false, do: {:halt, {:error, {op, name, other}}}, else: {:cont, :ok}
      end
    end)
  end

  @doc """
  Auto-activate workflow profile from project `.arvo/config.toml`.

  Trust does **not** block this path: project config is always readable (SPEC §5/§11).
  Project-local plugins under `<cwd>/.arvo/plugins/` remain trust-gated in
  `Arvo.Plugins.Registry` resolution. Bundled/global profile plugins still load
  when the project is untrusted.
  """
  def auto_activate_project(cwd, opts \\ []) do
    cfg = Arvo.Config.load(cwd)
    profile = cfg.profile
    # Drop trust_check if present — reserved key, not a switch option.
    switch_opts = Keyword.drop(opts, [:trust_check])

    cond do
      is_nil(profile) or profile == "" ->
        {:ok, :no_profile}

      true ->
        active = Arvo.Plugins.Registry.list_active()
        switch(profile, active, switch_opts)
    end
  end
end
