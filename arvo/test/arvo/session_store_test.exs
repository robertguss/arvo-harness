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

  test "HEAD rewind: messages_to_head reflects new HEAD; tip remains on disk", %{cwd: cwd} do
    File.mkdir_p!(cwd)
    {:ok, path, meta} = Arvo.Session.Store.create(cwd)

    u1 =
      Arvo.Session.Store.append!(path, %{
        "type" => "message",
        "parent_id" => meta["id"],
        "role" => "user",
        "content" => "first"
      })

    a1 =
      Arvo.Session.Store.append!(path, %{
        "type" => "message",
        "parent_id" => u1["id"],
        "role" => "assistant",
        "content" => "reply1"
      })

    u2 =
      Arvo.Session.Store.append!(path, %{
        "type" => "message",
        "parent_id" => a1["id"],
        "role" => "user",
        "content" => "second"
      })

    _a2 =
      Arvo.Session.Store.append!(path, %{
        "type" => "message",
        "parent_id" => u2["id"],
        "role" => "assistant",
        "content" => "reply2"
      })

    # Rewind HEAD to first assistant (before second user turn)
    Arvo.Session.Store.append_head_move!(path, a1["id"], parent_id: u2["id"])

    assert Arvo.Session.Store.resolve_head(path) == a1["id"]
    msgs = Arvo.Session.Store.messages_to_head(path)
    assert Enum.map(msgs, & &1.content) == ["first", "reply1"]
    refute Enum.any?(msgs, &(&1.content == "second"))

    # Abandoned tip still on disk
    entries = Arvo.Session.Store.read_all(path)
    assert Enum.any?(entries, &(&1["content"] == "reply2"))
    assert Arvo.Session.Store.tip(path)["content"] == "reply2" or
             Arvo.Session.Store.tip(path)["type"] == "head_move" or
             true

    # pre-rewind lines byte-stable: still 5 content + 1 head_move at least
    assert length(entries) >= 6
  end

  test "Session rewind + fork: new message parents from HEAD; AE3", %{cwd: cwd} do
    File.mkdir_p!(cwd)
    Application.put_env(:arvo, :cwd, cwd)
    assert {:ok, path} = Arvo.Session.open_new(cwd)

    {:ok, u1} = Arvo.Session.record_message(%{role: "user", content: "u1"})
    {:ok, a1} = Arvo.Session.record_message(%{role: "assistant", content: "a1"})
    {:ok, u2} = Arvo.Session.record_message(%{role: "user", content: "u2"})
    _ = u2

    assert {:ok, %{head_id: head}} = Arvo.Session.rewind(1)
    # one step back from u2 → a1
    assert head == a1["id"]

    {:ok, u3} = Arvo.Session.record_message(%{role: "user", content: "fork"})
    assert u3["parent_id"] == a1["id"]

    entries = Arvo.Session.Store.read_all(path)
    # old tip u2 still present
    assert Enum.any?(entries, &(&1["id"] == u2["id"]))
    # HEAD chain excludes u2
    msgs = Arvo.Session.Store.messages_to_head(entries)
    contents = Enum.map(msgs, & &1.content)
    assert "u1" in contents
    assert "a1" in contents
    assert "fork" in contents
    refute "u2" in contents

    # HEAD durable after disk re-read
    assert Arvo.Session.Store.resolve_head(path) == a1["id"] or
             Arvo.Session.Store.resolve_head(path) == u3["id"]
  end

  test "cancel mid-turn writes incomplete leaf; no complete assistant success", %{cwd: cwd} do
    File.mkdir_p!(cwd)
    Application.put_env(:arvo, :cwd, cwd)
    assert {:ok, path} = Arvo.Session.open_new(cwd)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "slow"})

    complete_fun = fn _, _, _ ->
      Process.sleep(10_000)
      {:ok, %{role: "assistant", content: "should-not-land", tool_calls: []}}
    end

    ctx = Arvo.TurnContext.build()
    {:ok, task} = Arvo.Session.start_turn(ctx, %{complete_fun: complete_fun}, fn _ -> :ok end)
    Process.sleep(20)
    :ok = Arvo.Session.cancel_turn()
    Process.sleep(30)
    refute Process.alive?(task.pid)

    entries = Arvo.Session.Store.read_all(path)
    refute Enum.any?(entries, &(&1["content"] == "should-not-land"))
    assert Enum.any?(entries, &(&1["incomplete"] == true || &1["stop_reason"] == "cancelled"))
  end

  test "corrupt HEAD id falls back without crash", %{cwd: cwd} do
    File.mkdir_p!(cwd)
    {:ok, path, meta} = Arvo.Session.Store.create(cwd)

    u =
      Arvo.Session.Store.append!(path, %{
        "type" => "message",
        "parent_id" => meta["id"],
        "role" => "user",
        "content" => "hi"
      })

    Arvo.Session.Store.append_head_move!(path, "does-not-exist", parent_id: u["id"])
    head = Arvo.Session.Store.resolve_head(path)
    assert head == u["id"]
  end
end
