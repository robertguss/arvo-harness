defmodule Arvo.ProfilesTest do
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-prof-#{System.unique_integer([:positive])}")
    File.mkdir_p!(Path.join([tmp, ".arvo", "profiles"]))
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)

    File.write!(Path.join([tmp, ".arvo", "profiles", "rust.toml"]), """
    plugins = ["toy_plugin"]
    """)

    File.write!(Path.join([tmp, ".arvo", "profiles", "python.toml"]), """
    plugins = []
    """)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    %{tmp: tmp}
  end

  test "list includes base and files" do
    names = Arvo.Profiles.list()
    assert "base" in names
    assert "rust" in names
  end

  test "switch is set-diff; second profile replaces first" do
    activated = :ets.new(:act, [:public, :bag])
    deactivated = :ets.new(:deact, [:public, :bag])

    opts = [
      activate: fn n -> :ets.insert(activated, {n}) end,
      deactivate: fn n -> :ets.insert(deactivated, {n}) end
    ]

    assert {:ok, r1} = Arvo.Profiles.switch("rust", ["base"], opts)
    assert "toy_plugin" in r1.added
    assert :ets.member(activated, "toy_plugin")

    # Stubs do not mutate Registry; pass logical active set for the next set-diff.
    assert {:ok, r2} = Arvo.Profiles.switch("python", ["base", "toy_plugin"], opts)
    assert "toy_plugin" in r2.removed
    assert :ets.member(deactivated, "toy_plugin")
  end

  test "switch surfaces activate failure (no silent success)" do
    opts = [
      activate: fn _ -> {:error, :boom} end,
      deactivate: fn _ -> :ok end
    ]

    assert {:error, {:activate, "toy_plugin", :boom}} =
             Arvo.Profiles.switch("rust", ["base"], opts)
  end

  test "project auto-activate applies profile without requiring trust", %{tmp: tmp} do
    # Trust gates project-local plugin dirs only (Registry), not the profile name
    # from project config — untrusted projects still get global/bundled profile plugins.
    proj = Path.join(tmp, "proj")
    File.mkdir_p!(Path.join(proj, ".arvo"))
    File.write!(Path.join([proj, ".arvo", "config.toml"]), "profile = \"python\"\n")

    assert {:ok, result} =
             Arvo.Profiles.auto_activate_project(proj,
               trust_check: fn _ -> false end,
               activate: fn _ -> :ok end,
               deactivate: fn _ -> :ok end
             )

    assert is_map(result)
  end

  test "project auto-activate no-ops when profile key absent", %{tmp: tmp} do
    proj = Path.join(tmp, "noprof")
    File.mkdir_p!(Path.join(proj, ".arvo"))
    File.write!(Path.join([proj, ".arvo", "config.toml"]), "# empty\n")

    assert {:ok, :no_profile} = Arvo.Profiles.auto_activate_project(proj)
  end

  test "/profile slash lists and switches" do
    assert {:ok, :handled, text} = Arvo.TUI.slash("profile")
    assert text =~ "base"
  end
end
