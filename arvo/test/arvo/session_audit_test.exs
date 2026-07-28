defmodule Arvo.SessionAuditTest do
  use ExUnit.Case, async: false

  alias Arvo.Session.Audit

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-audit-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    path = Path.join(tmp, "s.jsonl")
    File.write!(path, "")
    on_exit(fn -> File.rm_rf!(tmp) end)
    %{path: path}
  end

  test "append and list store_cold + stub_in_hot with sizes", %{path: path} do
    assert {:ok, _} = Audit.append(path, :store_cold, %{"id" => "c1", "size" => 9000, "tool" => "bash"})
    assert {:ok, _} = Audit.append(path, :stub_in_hot, %{"id" => "c1", "size" => 9000})

    events = Audit.list(path)
    assert length(events) == 2
    assert Enum.any?(events, &(&1["type"] == "store_cold" and &1["size"] == 9000))
    assert Enum.any?(events, &(&1["type"] == "stub_in_hot"))
    assert Enum.all?(events, &is_binary(&1["at"]))
  end

  test "metrics expose full_ingest_bytes and same_path_reinvoke", %{path: path} do
    _ = Audit.append(path, :full_hot, %{"size" => 5000})
    _ = Audit.append(path, :full_hot, %{"size" => 3000})
    _ = Audit.append(path, :same_path_reinvoke, %{"path" => "/a.ex"})

    m = Audit.metrics(path)
    assert m.full_hot == 2
    assert m.full_ingest_bytes == 8000
    assert m.same_path_reinvoke == 1
  end
end
