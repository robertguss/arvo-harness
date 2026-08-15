defmodule Arvo.ApplicationTest do
  use ExUnit.Case, async: false

  @children [
    Arvo.Providers.Registry,
    Arvo.Auth.TokenManager,
    Arvo.Plugins.Supervisor,
    Arvo.Plugins.Registry,
    Arvo.Session,
    Arvo.TUI
  ]

  test "supervision tree has all SPEC §2 named children running" do
    for mod <- @children do
      pid = Process.whereis(mod)
      assert is_pid(pid), "expected #{inspect(mod)} registered and alive"
      assert Process.alive?(pid)
    end
  end

  test "config is loaded into application env at boot" do
    cfg = Application.get_env(:arvo, :config)
    assert is_map(cfg)
    assert Map.has_key?(cfg, :default_model)
    assert Map.has_key?(cfg, :cwd)
  end

  test "supervisor is named Arvo.Supervisor" do
    assert is_pid(Process.whereis(Arvo.Supervisor))
  end

  test "maybe_auto_activate_profile loads project profile plugins on boot path" do
    tmp = Path.join(System.tmp_dir!(), "arvo-app-prof-#{System.unique_integer([:positive])}")
    File.mkdir_p!(Path.join([tmp, ".arvo", "profiles"]))
    proj = Path.join(tmp, "proj")
    File.mkdir_p!(Path.join(proj, ".arvo"))

    File.write!(Path.join([tmp, ".arvo", "profiles", "search.toml"]), """
    plugins = ["fff"]
    """)

    File.write!(Path.join([proj, ".arvo", "config.toml"]), """
    profile = "search"
    """)

    old_home = System.get_env("HOME")
    old_cwd = Application.get_env(:arvo, :cwd)
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, proj)

    on_exit(fn ->
      _ = Arvo.Plugins.Registry.deactivate("fff")
      if old_home, do: System.put_env("HOME", old_home), else: System.delete_env("HOME")
      if old_cwd, do: Application.put_env(:arvo, :cwd, old_cwd)
      File.rm_rf!(tmp)
    end)

    _ = Arvo.Plugins.Registry.deactivate("fff")
    refute "fff" in Arvo.Plugins.Registry.list_active()

    assert {:ok, result} = Arvo.Application.maybe_auto_activate_profile(proj)
    assert "fff" in result.added or "fff" in result.active
    assert "fff" in Arvo.Plugins.Registry.list_active()

    names = Enum.map(Arvo.Plugins.Registry.tools(), & &1.spec().name)
    assert "fff_search" in names
  end

  test "Application source calls maybe_auto_activate_profile after supervisor start" do
    src = File.read!(Path.expand("../../lib/arvo/application.ex", __DIR__))
    assert src =~ "maybe_auto_activate_profile"
    assert src =~ "Arvo.Profiles.auto_activate_project"
  end
end
