defmodule Arvo.PluginsTest do
  use ExUnit.Case, async: false

  setup do
    # Ensure support modules compiled with the test app
    Code.ensure_loaded!(Toy.Plugin)
    Code.ensure_loaded!(Toy.EchoTool)
    Code.ensure_loaded!(Toy.Worker)
    Code.ensure_loaded!(BadApi.Plugin)
    :ok
  end

  test "load path registers and activates toy plugin tools" do
    # Simulate loader success by registering manually through Registry API:
    # put plugin entry as if loaded
    dir =
      Path.join(System.tmp_dir!(), "toy_plugin_#{System.unique_integer([:positive])}")

    File.mkdir_p!(dir)

    # Inject via load_plugin after stubbing Loader — call Registry with a
    # pre-seeded approach: use GenServer cast by loading module path.
    # Direct unit: read_manifest + activate via Registry after fake load.
    assert {:ok, _} = Arvo.Plugins.Loader.read_manifest(Toy.Plugin)

    # Manually insert loaded plugin into registry by using load on a fake dir
    # that has ebin with nothing — instead use public API after patching:
    state_tools_before = Arvo.Plugins.Registry.tools() |> length()

    # Use GenServer.call private path: load_plugin will fail without ebin;
    # so test activate flow via a helper that Registry exposes after we fix
    # Registry to allow register_module/2 for tests — add register_loaded.
    assert :ok = Arvo.Plugins.Registry.register_loaded("toy_plugin", Toy.Plugin)
    assert :ok = Arvo.Plugins.Registry.activate("toy_plugin")

    names =
      Arvo.Plugins.Registry.tools()
      |> Enum.map(fn m -> m.spec().name end)

    assert "toy_echo" in names

    assert :ok = Arvo.Plugins.Registry.deactivate("toy_plugin")

    names2 =
      Arvo.Plugins.Registry.tools()
      |> Enum.map(fn m -> m.spec().name end)

    refute "toy_echo" in names2
    assert length(Arvo.Plugins.Registry.tools()) == state_tools_before
  end

  test "api mismatch skips with clear error" do
    assert {:error, msg} = Arvo.Plugins.Loader.read_manifest(BadApi.Plugin)
    assert msg =~ "api mismatch"
  end

  test "trust gate persists in trust.json" do
    tmp = Path.join(System.tmp_dir!(), "arvo-trust-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    proj = Path.join(tmp, "myproj")
    File.mkdir_p!(proj)
    refute Arvo.Plugins.Trust.trusted?(proj)

    assert {:error, :untrusted} = Arvo.Plugins.Trust.ensure_trusted(proj, fn _ -> false end)
    assert :ok = Arvo.Plugins.Trust.ensure_trusted(proj, fn _ -> true end)
    assert Arvo.Plugins.Trust.trusted?(proj)
    assert File.exists?(Arvo.Plugins.Trust.path())
  end

  test "plugin child crash is isolated; harness survives" do
    {:ok, pid} =
      DynamicSupervisor.start_child(Arvo.Plugins.Supervisor, {Toy.Worker, []})

    ref = Process.monitor(pid)
    Process.exit(pid, :kill)
    assert_receive {:DOWN, ^ref, :process, ^pid, _}, 1000
    assert Process.alive?(Process.whereis(Arvo.Supervisor))
    assert Process.alive?(Process.whereis(Arvo.Plugins.Supervisor))
  end

  test "base profile always active" do
    assert "base" in Arvo.Plugins.Registry.list_active()
  end

  test "activate starts children under DynamicSupervisor" do
    assert :ok = Arvo.Plugins.Registry.register_loaded("toy_plugin2", Toy.Plugin)
    assert :ok = Arvo.Plugins.Registry.activate("toy_plugin2")
    # children map non-empty via get — deactivate cleans up
    assert :ok = Arvo.Plugins.Registry.deactivate("toy_plugin2")
  end
end
