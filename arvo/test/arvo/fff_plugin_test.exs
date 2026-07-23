defmodule Arvo.FffPluginTest do
  use ExUnit.Case, async: false

  test "NIF artifact exists and Fff.Native.search/2 works" do
    so = Path.expand("../../priv/native/fff_search.so", __DIR__)
    assert File.exists?(so), "expected Rustler NIF at #{so}"

    tmp = Path.join(System.tmp_dir!(), "fff-nif-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    File.write!(Path.join(tmp, "hit.txt"), "unique_fff_nif_marker_99\n")

    assert {:ok, out} = Fff.Native.search("unique_fff_nif_marker_99", tmp)
    assert out =~ "unique_fff_nif_marker_99"
    assert out =~ "hit.txt"
    File.rm_rf!(tmp)
  end

  test "fff loads via standard register_loaded; search tool uses NIF" do
    assert {:ok, man} = Arvo.Plugins.Loader.read_manifest(Fff.Plugin)
    assert man.api == 1
    assert Fff.SearchTool in man.tools

    assert :ok = Arvo.Plugins.Registry.register_loaded("fff", Fff.Plugin)
    assert :ok = Arvo.Plugins.Registry.activate("fff")

    names = Enum.map(Arvo.Plugins.Registry.tools(), & &1.spec().name)
    assert "fff_search" in names

    tmp = Path.join(System.tmp_dir!(), "fff-search-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    File.write!(Path.join(tmp, "hit.txt"), "unique_fff_marker_42\n")

    assert {:ok, out} =
             Arvo.Tool.invoke(
               Fff.SearchTool,
               %{pattern: "unique_fff_marker_42", path: tmp},
               %{cwd: tmp}
             )

    assert out =~ "unique_fff_marker_42"
    assert :ok = Arvo.Plugins.Registry.deactivate("fff")
    File.rm_rf!(tmp)
  end

  test "product path: ensure_loaded + activate registers fff_search without manual register" do
    # May already be active from a prior test — deactivate first for isolation.
    _ = Arvo.Plugins.Registry.deactivate("fff")

    assert :ok = Arvo.Plugins.Registry.ensure_loaded("fff")
    assert :ok = Arvo.Plugins.Registry.activate("fff")
    assert "fff" in Arvo.Plugins.Registry.list_active()

    names = Enum.map(Arvo.Plugins.Registry.tools(), & &1.spec().name)
    assert "fff_search" in names

    assert :ok = Arvo.Plugins.Registry.deactivate("fff")
    refute "fff" in Arvo.Plugins.Registry.list_active()
  end

  test "product path: /profile search activates fff tools via set-diff" do
    tmp = Path.join(System.tmp_dir!(), "arvo-fff-prof-#{System.unique_integer([:positive])}")
    File.mkdir_p!(Path.join([tmp, ".arvo", "profiles"]))
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)

    on_exit(fn ->
      _ = Arvo.Plugins.Registry.deactivate("fff")
      if old, do: System.put_env("HOME", old), else: System.delete_env("HOME")
      File.rm_rf!(tmp)
    end)

    File.write!(Path.join([tmp, ".arvo", "profiles", "search.toml"]), """
    plugins = ["fff"]
    """)

    _ = Arvo.Plugins.Registry.deactivate("fff")
    active = Arvo.Plugins.Registry.list_active()

    assert {:ok, result} = Arvo.Profiles.switch("search", active)
    assert "fff" in result.added
    assert "fff" in result.active
    assert "fff" in Arvo.Plugins.Registry.list_active()

    names = Enum.map(Arvo.Plugins.Registry.tools(), & &1.spec().name)
    assert "fff_search" in names

    assert {:ok, :handled, text} = Arvo.TUI.slash("profile")
    assert text =~ "search" or text =~ "fff"
  end

  test "plugin dir + native crate present (structural)" do
    root = Path.expand("../../plugins/fff", __DIR__)
    assert File.dir?(root)
    assert File.exists?(Path.expand("../../native/fff_search/src/lib.rs", __DIR__))
    assert File.exists?(Path.expand("../../priv/native/fff_search.so", __DIR__))
  end
end
