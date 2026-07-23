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
  Switch workflow profile via set-diff against currently active (non-base) plugins.
  `activate_fun` / `deactivate_fun` receive plugin names.
  Returns `{:ok, %{added, removed, active}}`.
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

      removed = MapSet.difference(current, desired)
      added = MapSet.difference(desired, current)

      Enum.each(removed, deactivate_fun)
      Enum.each(added, activate_fun)
      _ = Arvo.Plugins.Registry.set_profile(new_profile)

      {:ok,
       %{
         added: MapSet.to_list(added),
         removed: MapSet.to_list(removed),
         active: ["base" | profile.plugins]
       }}
    end
  end

  @doc "Auto-activate profile from project config if trusted."
  def auto_activate_project(cwd, opts \\ []) do
    cfg = Arvo.Config.load(cwd)
    profile = cfg.profile
    trust_fun = Keyword.get(opts, :trust_check, &Arvo.Plugins.Trust.trusted?/1)

    cond do
      is_nil(profile) or profile == "" ->
        {:ok, :no_profile}

      not trust_fun.(cwd) ->
        {:error, :untrusted}

      true ->
        active = Arvo.Plugins.Registry.list_active()
        switch(profile, active, opts)
    end
  end
end
