defmodule Arvo.HandoffTest do
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-ho-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    {:ok, path} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "build the feature"})
    {:ok, _} = Arvo.Session.record_message(%{role: "assistant", content: "working on it"})
    {:ok, _} = Arvo.Session.record_usage(%{input_tokens: 50, output_tokens: 20})
    %{tmp: tmp, parent_path: path}
  end

  test "handoff creates new session; parent JSONL prior lines intact (AE4)", %{parent_path: parent} do
    parent_before = Arvo.Session.Store.read_all(parent)
    parent_ids = Enum.map(parent_before, & &1["id"])

    assert {:ok, result} = Arvo.Session.Handoff.perform()
    assert result.path != parent
    assert File.exists?(result.path)

    # Parent prior lines still present
    parent_after = Arvo.Session.Store.read_all(parent)

    for id <- parent_ids do
      assert Enum.any?(parent_after, &(&1["id"] == id))
    end

    # Child is packet-sized, not full parent transcript
    child_msgs = result.child_messages
    assert length(child_msgs) <= 2
    assert Enum.any?(child_msgs, fn m ->
             c = m[:content] || m["content"] || ""
             c =~ "handoff packet" or c =~ "goal:"
           end)

    # parent_session_id in packet
    assert is_binary(result.packet["parent_session_id"])

    # Session rebound to child
    assert Arvo.Session.get().path == result.path
  end

  test "packet contains required fields" do
    packet = Arvo.Session.Handoff.build_packet()

    for k <- ~w(goal done not_done paths last_error next_steps parent_session_id) do
      assert Map.has_key?(packet, k), "missing #{k}"
    end
  end

  test "resume parent keeps full cold log; child lacks full parent transcript", %{
    parent_path: parent
  } do
    assert {:ok, _} = Arvo.Session.Handoff.perform()
    child_path = Arvo.Session.get().path

    assert {:ok, parent_res} = Arvo.Session.resume(parent)
    parent_contents = Enum.map(parent_res.messages, & &1.content)
    assert Enum.any?(parent_contents, &(&1 =~ "build the feature"))

    assert {:ok, child_res} = Arvo.Session.resume(child_path)
    child_contents = Enum.map(child_res.messages, & &1.content)
    refute Enum.any?(child_contents, &(&1 == "working on it"))
  end

  test "/handoff slash works", %{tmp: _tmp} do
    assert {:ok, :handled, msg} = Arvo.TUI.slash("handoff")
    assert msg =~ "handoff ok"
  end
end
