defmodule Arvo.SessionColdTest do
  use ExUnit.Case, async: true

  alias Arvo.Session.Cold

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-cold-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    session_path = Path.join(tmp, "sess_test.jsonl")
    File.write!(session_path, "")
    on_exit(fn -> File.rm_rf!(tmp) end)
    %{session_path: session_path, tmp: tmp}
  end

  test "store and fetch round-trip preserves multi-KB body", %{session_path: path} do
    body = String.duplicate("line of log output\n", 500)
    assert byte_size(body) > 5_000

    assert {:ok, entry} = Cold.store(path, body, %{"tool" => "bash", "kind" => "tool_result"})
    assert is_binary(entry["id"])
    assert entry["size"] == byte_size(body)
    assert entry["tool"] == "bash"

    assert {:ok, fetched} = Cold.fetch(path, entry["id"])
    assert fetched == body
  end

  test "missing id returns honest error", %{session_path: path} do
    assert {:error, :not_found} = Cold.fetch(path, "does-not-exist")
  end

  test "list returns session entries after store; complete after stub simulation", %{
    session_path: path
  } do
    body = String.duplicate("x", 2_000)
    assert {:ok, e1} = Cold.store(path, body, %{"tool" => "bash"})
    assert {:ok, e2} = Cold.store(path, "small", %{"tool" => "read", "source_path" => "/a.ex"})

    entries = Cold.list(path)
    assert length(entries) == 2
    ids = Enum.map(entries, & &1["id"])
    assert e1["id"] in ids
    assert e2["id"] in ids

    # Session-scoped completeness: bodies remain after we only keep stubs in hot
    assert {:ok, ^body} = Cold.fetch(path, e1["id"])
    assert {:ok, "small"} = Cold.fetch(path, e2["id"])
  end

  test "cold dir is session-local sidecar beside jsonl", %{session_path: path} do
    assert {:ok, entry} = Cold.store(path, "hello", %{})
    dir = Cold.cold_dir(path)
    assert File.dir?(dir)
    assert String.starts_with?(dir, Path.dirname(path))
    assert File.exists?(Path.join(dir, entry["id"] <> ".body"))
  end
end
