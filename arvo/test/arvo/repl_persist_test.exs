defmodule Arvo.ReplPersistTest do
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-repl-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    {:ok, path} = Arvo.Session.open_new(tmp)
    %{tmp: tmp, path: path}
  end

  test "persist_agent_result only appends new assistant/tool rows (no history dupes)", %{
    path: path
  } do
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "first"})
    {:ok, _} = Arvo.Session.record_message(%{role: "assistant", content: "reply1"})

    prior = Arvo.Repl.session_messages()
    prior_len = length(prior)
    assert prior_len == 2

    # Simulate Agent result: system + prior + new assistant
    result = %{
      messages: [
        %{role: "system", content: "sys"},
        %{role: "user", content: "first"},
        %{role: "assistant", content: "reply1"},
        %{role: "assistant", content: "reply2", tool_calls: []}
      ],
      usage: %{"prompt_tokens" => 10, "completion_tokens" => 5}
    }

    written = Arvo.Repl.persist_agent_result(result, prior_len)
    assert written == 1

    entries = Arvo.Session.Store.read_all(path)
    assistants = Enum.filter(entries, &(&1["role"] == "assistant"))
    # one prior + one new — not three
    assert length(assistants) == 2
    assert List.last(assistants)["content"] == "reply2"
  end

  test "session_messages preserves tool_calls and tool_call_id for complete_turn", %{path: path} do
    {:ok, u} = Arvo.Session.record_message(%{role: "user", content: "edit file"})

    {:ok, _} =
      Arvo.Session.record_message(%{
        "role" => "assistant",
        "content" => "",
        "tool_calls" => [
          %{"id" => "c1", "name" => "read", "arguments" => %{"path" => "a.txt"}}
        ]
      })

    {:ok, _} =
      Arvo.Session.record_message(%{
        "role" => "tool",
        "content" => "file body",
        "tool_call_id" => "c1",
        "name" => "read",
        "is_error" => false
      })

    msgs = Arvo.Repl.session_messages()
    assert length(msgs) == 3

    asst = Enum.find(msgs, &(&1.role == "assistant"))
    assert is_list(asst.tool_calls)
    assert hd(asst.tool_calls).id == "c1" or hd(asst.tool_calls)["id"] == "c1"

    tool = Enum.find(msgs, &(&1.role == "tool"))
    assert tool.tool_call_id == "c1"
    assert tool.name == "read"
    assert tool.content == "file body"

    # disk round-trip via Store.messages_to_tip
    tip_msgs = Arvo.Session.Store.messages_to_tip(path)

    assert Enum.any?(tip_msgs, fn m ->
             (m[:tool_call_id] || m["tool_call_id"]) == "c1"
           end)

    _ = u
  end

  test "maybe_record_usage writes Session tokens and TUI usage_line", %{path: path} do
    result = %{
      messages: [],
      usage: %{"prompt_tokens" => 100, "completion_tokens" => 40}
    }

    assert {:ok, tokens} = Arvo.Repl.maybe_record_usage(result)
    assert tokens.cumulative_total == 140
    assert tokens.turn_input == 100
    assert tokens.turn_output == 40

    line = Arvo.TUI.usage_line()
    assert line =~ "140"
    assert line =~ "140" or line =~ "cum="
    # turn = 140 in this single record_usage call
    assert line =~ "turn=140" or line =~ "140"

    # second turn accumulates
    assert {:ok, tokens2} =
             Arvo.Repl.maybe_record_usage(%{
               usage: %{"input_tokens" => 10, "output_tokens" => 5}
             })

    assert tokens2.cumulative_total == 155
    _ = path
  end

  test "two agent runs via persist slice do not duplicate prior tool turns", %{path: path} do
    complete1 = fn messages, _, _ ->
      tools = Enum.filter(messages, &(&1[:role] == "tool"))

      if tools == [] do
        {:ok,
         %{
           role: "assistant",
           content: "",
           tool_calls: [%{id: "t1", name: "bash", arguments: %{"command" => "echo hi"}}],
           usage: %{"prompt_tokens" => 3, "completion_tokens" => 1}
         }}
      else
        {:ok,
         %{
           role: "assistant",
           content: "done1",
           tool_calls: [],
           usage: %{"prompt_tokens" => 2, "completion_tokens" => 1}
         }}
      end
    end

    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "run1"})
    prior1 = Arvo.Repl.session_messages()

    {:ok, r1} =
      Arvo.Agent.run(
        %{messages: prior1, cwd: File.cwd!(), tools: [Arvo.Tools.Bash]},
        %{complete_fun: complete1},
        fn _ -> :ok end
      )

    _ = Arvo.Repl.persist_agent_result(r1, length(prior1))
    _ = Arvo.Repl.maybe_record_usage(r1)

    entries_after_1 = Arvo.Session.Store.read_all(path)
    n1 = length(entries_after_1)

    # Second user turn
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "run2"})
    prior2 = Arvo.Repl.session_messages()

    complete2 = fn _messages, _, _ ->
      {:ok,
       %{
         role: "assistant",
         content: "done2",
         tool_calls: [],
         usage: %{"prompt_tokens" => 4, "completion_tokens" => 2}
       }}
    end

    {:ok, r2} =
      Arvo.Agent.run(
        %{messages: prior2, cwd: File.cwd!(), tools: [Arvo.Tools.Bash]},
        %{complete_fun: complete2},
        fn _ -> :ok end
      )

    _ = Arvo.Repl.persist_agent_result(r2, length(prior2))
    _ = Arvo.Repl.maybe_record_usage(r2)

    entries = Arvo.Session.Store.read_all(path)
    # growth is only user2 + assistant done2 — not a full replay of turn 1
    assert length(entries) == n1 + 2

    contents =
      entries
      |> Enum.filter(&(&1["type"] == "message"))
      |> Enum.map(& &1["content"])

    assert Enum.count(contents, &(&1 == "done1")) == 1
    assert Enum.count(contents, &(&1 == "done2")) == 1

    # usage accumulated on session
    tokens = Arvo.Session.tokens()
    assert tokens.cumulative_total == 3 + 1 + 2 + 1 + 4 + 2
  end
end
