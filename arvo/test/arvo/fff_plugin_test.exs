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

  test "plugin dir + native crate present (structural)" do
    root = Path.expand("../../plugins/fff", __DIR__)
    assert File.dir?(root)
    assert File.exists?(Path.expand("../../native/fff_search/src/lib.rs", __DIR__))
    assert File.exists?(Path.expand("../../priv/native/fff_search.so", __DIR__))
  end
end
