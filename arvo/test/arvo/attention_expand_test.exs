defmodule Arvo.AttentionExpandTest do
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-exp-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)
    Application.put_env(:arvo, :progressive_attention, true)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      Application.put_env(:arvo, :progressive_attention, true)
      File.rm_rf!(tmp)
    end)

    {:ok, path} = Arvo.Session.open_new(tmp)
    %{tmp: tmp, path: path}
  end

  test "expand within cap succeeds; over cap honest fail", %{path: path} do
    body = String.duplicate("z", 20_000)
    assert {:ok, entry} = Arvo.Session.Cold.store(path, body, %{"tool" => "bash"})
    id = entry["id"]

    assert {:ok, slice} = Arvo.Session.recall(id, actor: :user, cap_bytes: 50_000, max_bytes: 8_000)
    assert byte_size(slice) <= 8_000 + 80
    assert slice =~ "z"

    assert {:error, :over_cap} =
             Arvo.Session.recall(id, actor: :user, cap_bytes: 100, max_bytes: 50_000)

    events = Arvo.Session.Audit.list(path)
    assert Enum.any?(events, &(&1["type"] == "expand"))
    assert Enum.any?(events, &(&1["type"] == "denied_expand"))
  end

  test "second full-path Read of unchanged P does not double full-hot when cold exists", %{
    path: path
  } do
    large = String.duplicate("defmodule X\n", 800)
    assert byte_size(large) > 4_000

    r1 =
      Arvo.Session.project_tool_result("read", %{"path" => "lib/x.ex"}, large, false)

    # First large read may be fidelity full_hot
    assert r1.cold_id

    r2 =
      Arvo.Session.project_tool_result("read", %{"path" => "lib/x.ex"}, large, false)

    assert r2.action == :stub
    assert r2.content =~ "[cold:"
    refute r2.content == large

    m = Arvo.Session.Audit.metrics(path)
    assert m.same_path_reinvoke >= 1
    assert m.store_cold >= 2
  end
end
