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
end
