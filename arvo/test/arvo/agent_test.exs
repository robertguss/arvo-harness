defmodule Arvo.AgentTest do
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-agent-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    File.write!(Path.join(tmp, "note.txt"), "hello world\n")
    on_exit(fn -> File.rm_rf!(tmp) end)
    %{tmp: tmp}
  end

  test "event stream order for multi-tool sequential turn", %{tmp: tmp} do
    # Ordered list (not unique_integer) — monotonic insert order is the contract under test
    events = :ets.new(:events, [:public, :ordered_set])
    counter = :atomics.new(1, signed: false)

    event_fun = fn ev ->
      n = :atomics.add_get(counter, 1, 1)
      :ets.insert(events, {n, ev})
    end

    # Scripted model: turn0 tool calls read+edit+bash; turn1 final answer
    complete_fun = fn messages, _specs, _config ->
      tool_results =
        Enum.filter(messages, fn m -> Map.get(m, :role) == "tool" end)

      if tool_results == [] do
        {:ok,
         %{
           role: "assistant",
           content: "",
           tool_calls: [
             %{id: "1", name: "read", arguments: %{"path" => "note.txt"}},
             %{
               id: "2",
               name: "edit",
               arguments: %{
                 "path" => "note.txt",
                 "old_string" => "hello world",
                 "new_string" => "hello arvo"
               }
             },
             %{id: "3", name: "bash", arguments: %{"command" => "cat note.txt"}}
           ]
         }}
      else
        {:ok, %{role: "assistant", content: "done", tool_calls: []}}
      end
    end

    {:ok, result} =
      Arvo.Agent.run(
        %{
          messages: [%{role: "user", content: "change note.txt"}],
          cwd: tmp,
          session_id: "t1"
        },
        %{complete_fun: complete_fun, max_turns: 5},
        event_fun
      )

    assert result.stop_reason == :end_turn
    assert File.read!(Path.join(tmp, "note.txt")) =~ "hello arvo"

    types =
      :ets.tab2list(events)
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map(fn {_, {type, _}} -> type end)

    assert :agent_start in types
    assert :turn_start in types
    assert :tool_call_start in types
    assert :tool_call_end in types
    assert :turn_end in types
    assert :agent_end in types
    assert Enum.find_index(types, &(&1 == :agent_start)) <
             Enum.find_index(types, &(&1 == :agent_end))
  end

  test "invalid tool name returned as error tool-result, loop continues", %{tmp: tmp} do
    complete_fun = fn messages, _, _ ->
      if Enum.any?(messages, &(&1[:role] == "tool")) do
        {:ok, %{role: "assistant", content: "repaired", tool_calls: []}}
      else
        {:ok,
         %{
           role: "assistant",
           content: "",
           tool_calls: [%{id: "x", name: "nope", arguments: %{}}]
         }}
      end
    end

    events = []
    {:ok, result} =
      Arvo.Agent.run(
        %{messages: [%{role: "user", content: "x"}], cwd: tmp},
        %{complete_fun: complete_fun},
        fn _ -> :ok end
      )

    tool_msg = Enum.find(result.messages, &(&1[:role] == "tool"))
    assert tool_msg.is_error
    assert tool_msg.content =~ "Unknown tool"
    assert result.stop_reason == :end_turn
    _ = events
  end

  test "steering drained after tools complete", %{tmp: tmp} do
    complete_fun = fn messages, _, _ ->
      users = Enum.filter(messages, &(&1[:role] == "user"))
      tools = Enum.filter(messages, &(&1[:role] == "tool"))

      cond do
        tools == [] and length(users) == 1 ->
          {:ok,
           %{
             role: "assistant",
             content: "",
             tool_calls: [%{id: "1", name: "bash", arguments: %{"command" => "echo hi"}}]
           }}

        true ->
          # After tools + steering user message, end
          {:ok, %{role: "assistant", content: "acked", tool_calls: []}}
      end
    end

    {:ok, result} =
      Arvo.Agent.run(
        %{
          messages: [%{role: "user", content: "start"}],
          cwd: tmp,
          steering: ["please also summarize"]
        },
        %{complete_fun: complete_fun, max_turns: 5},
        fn _ -> :ok end
      )

    users = Enum.filter(result.messages, &(&1[:role] == "user"))
    assert Enum.any?(users, &(&1.content =~ "summarize"))
    assert result.steering == []
  end

  test "killing turn Task cancels; session survives", %{tmp: tmp} do
    complete_fun = fn _, _, _ ->
      Process.sleep(5_000)
      {:ok, %{role: "assistant", content: "late", tool_calls: []}}
    end

    {:ok, task} =
      Arvo.Session.start_turn(
        %{messages: [%{role: "user", content: "slow"}], cwd: tmp},
        %{complete_fun: complete_fun},
        fn _ -> :ok end
      )

    assert Process.alive?(task.pid)
    :ok = Arvo.Session.cancel_turn()
    Process.sleep(50)
    refute Process.alive?(task.pid)
    # harness still up
    assert is_pid(Process.whereis(Arvo.Session))
    assert is_pid(Process.whereis(Arvo.Supervisor))
  end
end
