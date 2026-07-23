defmodule Arvo.Plugins.Loader do
  @moduledoc """
  Load a plugin mix project: `mix compile`, `Code.add_path`, resolve entry module.
  """

  @doc """
  Discover and load a plugin directory. Returns `{:ok, mod, manifest}` or `{:error, reason}`.
  """
  def load(plugin_dir, opts \\ []) do
    plugin_dir = Path.expand(plugin_dir)
    compile? = Keyword.get(opts, :compile, true)

    with :ok <- ensure_dir(plugin_dir),
         :ok <- maybe_compile(plugin_dir, compile?),
         :ok <- add_ebin(plugin_dir),
         {:ok, mod} <- entry_module(plugin_dir),
         {:ok, manifest} <- read_manifest(mod) do
      {:ok, mod, manifest}
    end
  end

  def entry_module(plugin_dir) do
    name = Path.basename(plugin_dir)
    # toy → Toy.Plugin; fff → Fff.Plugin
    mod_name =
      name
      |> String.split(~r/[^A-Za-z0-9]+/)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&String.capitalize/1)
      |> Enum.join()
      |> then(&Module.concat([&1 <> ".Plugin"]))

    # Ensure beam is loaded
    case Code.ensure_loaded(mod_name) do
      {:module, ^mod_name} ->
        {:ok, mod_name}

      _ ->
        # Try scanning ebin for *Plugin.beam
        ebin = ebin_path(plugin_dir)

        case File.ls(ebin) do
          {:ok, files} ->
            files
            |> Enum.filter(&String.ends_with?(&1, "Plugin.beam"))
            |> case do
              [beam | _] ->
                # beam filename is Elixir.Foo.Plugin.beam
                mod =
                  beam
                  |> String.trim_trailing(".beam")
                  |> String.to_existing_atom()

                {:ok, mod}

              _ ->
                {:error, "no plugin entry module for #{plugin_dir} (expected #{inspect(mod_name)})"}
            end

          _ ->
            {:error, "no ebin for #{plugin_dir}"}
        end
    end
  rescue
    e -> {:error, Exception.message(e)}
  end

  def read_manifest(mod) do
    Code.ensure_loaded(mod)

    if function_exported?(mod, :manifest, 0) do
      m = mod.manifest()
      api = m[:api] || m["api"]

      if api == Arvo.Plugin.plugin_api() do
        {:ok, normalize_manifest(m)}
      else
        {:error,
         "plugin api mismatch: #{inspect(mod)} has api=#{inspect(api)}, harness wants #{Arvo.Plugin.plugin_api()}"}
      end
    else
      {:error, "#{inspect(mod)} does not export manifest/0"}
    end
  end

  defp normalize_manifest(m) do
    %{
      api: m[:api] || m["api"] || 1,
      tools: m[:tools] || m["tools"] || [],
      skills: m[:skills] || m["skills"] || [],
      children: m[:children] || m["children"] || [],
      commands: m[:commands] || m["commands"] || [],
      hooks: m[:hooks] || m["hooks"] || []
    }
  end

  defp ensure_dir(dir) do
    if File.dir?(dir), do: :ok, else: {:error, "not a directory: #{dir}"}
  end

  defp maybe_compile(_dir, false), do: :ok

  defp maybe_compile(dir, true) do
    # If beams already present, skip mix for speed in tests
    ebin = ebin_path(dir)

    if File.dir?(ebin) and match?({:ok, [_ | _]}, File.ls(ebin)) do
      :ok
    else
      case System.cmd("mix", ["compile"], cd: dir, stderr_to_stdout: true) do
        {_, 0} -> :ok
        {out, code} -> {:error, "mix compile failed (#{code}): #{String.slice(out, 0, 500)}"}
      end
    end
  end

  defp add_ebin(dir) do
    ebin = ebin_path(dir)

    if File.dir?(ebin) do
      Code.append_path(ebin)
      :ok
    else
      {:error, "missing ebin: #{ebin}"}
    end
  end

  def ebin_path(plugin_dir) do
    # Prefer _build/dev/lib/<app>/ebin if present
    build = Path.join([plugin_dir, "_build", "dev", "lib"])

    case File.ls(build) do
      {:ok, [app | _]} -> Path.join([build, app, "ebin"])
      _ -> Path.join([plugin_dir, "ebin"])
    end
  end
end
