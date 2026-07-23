defmodule Arvo.SessionStoreTest do
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-sess-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    on_exit(fn ->
      if old, do: System.put_env("HOME", old), else: System.delete_env("HOME")
      File.rm_rf!(tmp)
    end)

    %{tmp: tmp, cwd: Path.join(tmp, "proj")}
  end

  test "append-only JSONL tree; session_meta first; unique ids", %{cwd: cwd} do
    File.mkdir_p!(cwd)
    {:ok, path, meta} = Arvo.Session.Store.create(cwd, model: "xai:grok-4.5")
    assert meta["type"] == "session_meta"
    assert meta["parent_id"] == nil

    u =
      Arvo.Session.Store.append!(path, %{
        "type" => "message",
        "parent_id" => meta["id"],
        "role" => "user",
        "content" => "hi"
      })

    a =
      Arvo.Session.Store.append!(path, %{
        "type" => "message",
        "parent_id" => u["id"],
        "role" => "assistant",
        "content" => "hello"
      })

    entries = Arvo.Session.Store.read_all(path)
    assert length(entries) == 3
    assert Arvo.Session.Store.valid_tree?(entries)
    assert Arvo.Session.Store.tip(path)["id"] == a["id"]
  end

  test "kill-style durability: prior entries readable after reopen", %{cwd: cwd} do
    File.mkdir_p!(cwd)
    {:ok, path, meta} = Arvo.Session.Store.create(cwd)

    Arvo.Session.Store.append!(path, %{
      "type" => "message",
      "parent_id" => meta["id"],
      "role" => "user",
      "content" => "persist me"
    })

    # Simulate process death: just re-read from disk
    entries = Arvo.Session.Store.read_all(path)
    assert Enum.any?(entries, &(&1["content"] == "persist me"))
  end

  test "resume-from-tip reconstructs messages", %{cwd: cwd} do
    File.mkdir_p!(cwd)
    {:ok, path, meta} = Arvo.Session.Store.create(cwd)

    u =
      Arvo.Session.Store.append!(path, %{
        "type" => "message",
        "parent_id" => meta["id"],
        "role" => "user",
        "content" => "one"
      })

    Arvo.Session.Store.append!(path, %{
      "type" => "message",
      "parent_id" => u["id"],
      "role" => "assistant",
      "content" => "two"
    })

    msgs = Arvo.Session.Store.messages_to_tip(path)
    assert Enum.map(msgs, & &1.content) == ["one", "two"]
  end

  test "Session GenServer open/record/resume + tokens", %{cwd: cwd} do
    File.mkdir_p!(cwd)
    assert {:ok, path} = Arvo.Session.open_new(cwd)
    assert File.exists?(path)

    assert {:ok, _} =
             Arvo.Session.record_message(%{role: "user", content: "hello session"})

    assert {:ok, tokens} =
             Arvo.Session.record_usage(%{input_tokens: 10, output_tokens: 5})

    assert tokens.cumulative_total == 15

    assert {:ok, %{messages: msgs}} = Arvo.Session.resume(path)
    assert Enum.any?(msgs, &(&1.content =~ "hello"))
  end

  test "list_resumable_for_cwd drops meta-only sessions", %{cwd: cwd} do
    File.mkdir_p!(cwd)
    {:ok, empty, _meta} = Arvo.Session.Store.create(cwd)
    {:ok, full, meta} = Arvo.Session.Store.create(cwd)

    Arvo.Session.Store.append!(full, %{
      "type" => "message",
      "parent_id" => meta["id"],
      "role" => "user",
      "content" => "hi"
    })

    all = Arvo.Session.Store.list_for_cwd(cwd)
    resumable = Arvo.Session.Store.list_resumable_for_cwd(cwd)

    assert empty in all
    assert full in all
    refute empty in resumable
    assert full in resumable
  end
end
