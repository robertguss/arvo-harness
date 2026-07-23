defmodule Arvo.Plugins.Registry do
  @moduledoc """
  Loaded/active plugins, tool + skill + profile state. base profile always active.
  """
  use GenServer

  # Flagship plugins compiled into the arvo app (NIF otp_app: :arvo).
  # External mix plugins still load from ~/.arvo/plugins or project .arvo/plugins.
  @bundled %{"fff" => Fff.Plugin}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def list_active, do: GenServer.call(__MODULE__, :list_active)
  def tools, do: GenServer.call(__MODULE__, :tools)
  def load_plugin(dir, opts \\ []), do: GenServer.call(__MODULE__, {:load_plugin, dir, opts}, 120_000)

  @doc "Test/helper: register an already-loaded entry module without mix compile."
  def register_loaded(name, mod) when is_binary(name) and is_atom(mod) do
    GenServer.call(__MODULE__, {:register_loaded, name, mod})
  end

  @doc """
  Ensure plugin `name` is loaded into the registry (not necessarily active).

  Resolution order:
  1. already registered
  2. bundled in-app module (e.g. fff → Fff.Plugin)
  3. `~/.arvo/plugins/<name>/` mix project
  4. `<cwd>/.arvo/plugins/<name>/` when project is trusted
  """
  def ensure_loaded(name) when is_binary(name) do
    GenServer.call(__MODULE__, {:ensure_loaded, name}, 120_000)
  end

  @doc "Load if needed, then activate. Surfaces load errors as activate failures."
  def activate(name) when is_binary(name) do
    case ensure_loaded(name) do
      :ok -> GenServer.call(__MODULE__, {:activate, name})
      {:error, _} = err -> err
    end
  end

  def deactivate(name), do: GenServer.call(__MODULE__, {:deactivate, name})
  def set_profile(name), do: GenServer.call(__MODULE__, {:set_profile, name})

  @impl true
  def init(_opts) do
    {:ok,
     %{
       plugins: %{},
       active: MapSet.new(["base"]),
       tools: core_tool_map(),
       skills: [],
       profile: "base",
       child_pids: %{}
     }}
  end

  @impl true
  def handle_call(:list_active, _from, state) do
    {:reply, MapSet.to_list(state.active), state}
  end

  def handle_call(:tools, _from, state) do
    {:reply, Map.values(state.tools), state}
  end

  def handle_call({:load_plugin, dir, opts}, _from, state) do
    case Arvo.Plugins.Loader.load(dir, opts) do
      {:ok, mod, manifest} ->
        name = Path.basename(Path.expand(dir))

        entry = %{
          name: name,
          module: mod,
          manifest: manifest,
          dir: Path.expand(dir),
          status: :loaded
        }

        state = put_in(state, [:plugins, name], entry)
        {:reply, {:ok, name}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:register_loaded, name, mod}, _from, state) do
    case put_loaded(state, name, mod, nil) do
      {:ok, state} -> {:reply, :ok, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:ensure_loaded, name}, _from, state) do
    case do_ensure_loaded(state, name) do
      {:ok, state} -> {:reply, :ok, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:activate, name}, _from, state) do
    case Map.get(state.plugins, name) do
      nil ->
        {:reply, {:error, :not_loaded}, state}

      %{status: :active} ->
        # Already active — idempotent success (profile re-switch / set-diff edge).
        {:reply, :ok, state}

      entry ->
        ctx = %{cwd: Application.get_env(:arvo, :cwd)}

        case entry.module.activate(ctx) do
          :ok ->
            state = start_children(state, name, entry.manifest.children)
            tools = register_tools(state.tools, entry.manifest.tools)
            active = MapSet.put(state.active, name)
            entry = %{entry | status: :active}
            state = %{state | plugins: Map.put(state.plugins, name, entry), active: active, tools: tools}
            {:reply, :ok, state}

          {:error, reason} ->
            {:reply, {:error, reason}, state}
        end
    end
  end

  def handle_call({:deactivate, name}, _from, state) do
    if name == "base" do
      {:reply, {:error, :base_always_active}, state}
    else
      case Map.get(state.plugins, name) do
        nil ->
          {:reply, {:error, :not_loaded}, state}

        entry ->
          _ = entry.module.deactivate(%{})
          state = stop_children(state, name)
          tools = unregister_tools(state.tools, entry.manifest.tools)
          active = MapSet.delete(state.active, name)
          entry = %{entry | status: :deactivated}
          state = %{state | plugins: Map.put(state.plugins, name, entry), active: active, tools: tools}
          {:reply, :ok, state}
      end
    end
  end

  def handle_call({:set_profile, name}, _from, state) do
    {:reply, :ok, %{state | profile: name}}
  end

  defp do_ensure_loaded(state, name) do
    cond do
      Map.has_key?(state.plugins, name) ->
        {:ok, state}

      (bundled = Map.get(@bundled, name)) && match?({:module, _}, Code.ensure_loaded(bundled)) ->
        put_loaded(state, name, bundled, :bundled)

      (dir = resolve_plugin_dir(name)) != nil ->
        case Arvo.Plugins.Loader.load(dir) do
          {:ok, mod, manifest} ->
            entry = %{
              name: name,
              module: mod,
              manifest: manifest,
              dir: Path.expand(dir),
              status: :loaded
            }

            {:ok, put_in(state, [:plugins, name], entry)}

          {:error, reason} ->
            {:error, reason}
        end

      true ->
        {:error, {:not_found, name}}
    end
  end

  defp put_loaded(state, name, mod, dir) do
    case Arvo.Plugins.Loader.read_manifest(mod) do
      {:ok, manifest} ->
        entry = %{
          name: name,
          module: mod,
          manifest: manifest,
          dir: dir,
          status: :loaded
        }

        {:ok, put_in(state, [:plugins, name], entry)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp resolve_plugin_dir(name) do
    home = System.get_env("HOME") || System.user_home!()
    cwd = Application.get_env(:arvo, :cwd) || Arvo.cwd()

    global = Path.join([home, ".arvo", "plugins", name])
    project = Path.join([cwd, ".arvo", "plugins", name])

    cond do
      File.dir?(global) ->
        global

      File.dir?(project) and Arvo.Plugins.Trust.trusted?(cwd) ->
        project

      true ->
        nil
    end
  end

  defp core_tool_map do
    Arvo.Tool.core_tools()
    |> Map.new(fn mod -> {mod.spec().name, mod} end)
  end

  defp register_tools(tools, mods) do
    Enum.reduce(mods, tools, fn mod, acc ->
      Map.put(acc, mod.spec().name, mod)
    end)
  end

  defp unregister_tools(tools, mods) do
    Enum.reduce(mods, tools, fn mod, acc ->
      Map.delete(acc, mod.spec().name)
    end)
  end

  defp start_children(state, name, children) do
    pids =
      Enum.reduce(children, [], fn child, acc ->
        case DynamicSupervisor.start_child(Arvo.Plugins.Supervisor, child) do
          {:ok, pid} -> [pid | acc]
          {:ok, pid, _} -> [pid | acc]
          {:error, {:already_started, pid}} -> [pid | acc]
          _ -> acc
        end
      end)

    put_in(state, [:child_pids, name], pids)
  end

  defp stop_children(state, name) do
    for pid <- Map.get(state.child_pids, name, []) do
      _ = DynamicSupervisor.terminate_child(Arvo.Plugins.Supervisor, pid)
    end

    %{state | child_pids: Map.delete(state.child_pids, name)}
  end
end
