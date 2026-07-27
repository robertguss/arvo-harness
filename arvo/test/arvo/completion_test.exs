defmodule Arvo.CompletionTest do
  use ExUnit.Case, async: false

  test "config default_model is xai:grok-4.5 shape" do
    Application.put_env(:arvo, :config, %{
      default_model: "xai:grok-4.5",
      providers: %{},
      profile: nil,
      cwd: "/"
    })

    cfg = Application.get_env(:arvo, :config)
    assert cfg.default_model == "xai:grok-4.5"
  end

  test "repl handle_line routes login and chat" do
    assert Arvo.Repl.handle_line("/login") == {:slash, "login", ""}
    assert Arvo.Repl.handle_line("hello model") == {:chat, "hello model"}
    assert Arvo.Repl.handle_line("quit") == :quit
  end

  test "providers registry has grok entry" do
    entry = Arvo.Providers.Registry.get("grok")
    assert entry.prefix == "xai"
    assert entry.auth == :oauth
    assert entry.base_url =~ "api.x.ai"
  end

  test "parse_sse_stream emits multiple text deltas and assembles content" do
    body = """
    data: {"choices":[{"delta":{"content":"Hel"}}]}

    data: {"choices":[{"delta":{"content":"lo "}}]}

    data: {"choices":[{"delta":{"content":"world"}}]}

    data: {"choices":[{"delta":{},"finish_reason":"stop"}],"usage":{"prompt_tokens":3,"completion_tokens":2}}

    data: [DONE]

    """

    deltas = :ets.new(:deltas, [:public, :bag])
    on_delta = fn t -> :ets.insert(deltas, {:d, t}) end

    assert {:ok, result} = Arvo.Providers.Completion.parse_sse_stream(body, on_delta)
    assert result.content == "Hello world"
    assert result.streamed? == true
    assert result.tool_calls == []
    assert length(:ets.lookup(deltas, :d)) == 3
  end

  test "parse_sse_stream assembles tool_calls fully before return" do
    body = """
    data: {"choices":[{"delta":{"tool_calls":[{"index":0,"id":"c1","function":{"name":"read","arguments":""}}]}}]}

    data: {"choices":[{"delta":{"tool_calls":[{"index":0,"function":{"arguments":"{\\"path\\""}}]}}]}

    data: {"choices":[{"delta":{"tool_calls":[{"index":0,"function":{"arguments":":\\"a.txt\\"}"}}]}}]}

    data: [DONE]

    """

    assert {:ok, result} = Arvo.Providers.Completion.parse_sse_stream(body, fn _ -> :ok end)
    assert result.content == ""
    assert length(result.tool_calls) == 1
    [tc] = result.tool_calls
    assert tc.id == "c1"
    assert tc.name == "read"
    assert tc.arguments["path"] == "a.txt"
  end

  test "complete_turn with stream_body uses registry base_url shape and streams" do
    body = """
    data: {"choices":[{"delta":{"content":"a"}}]}

    data: {"choices":[{"delta":{"content":"b"}}]}

    data: [DONE]

    """

    parent = self()

    assert {:ok, result} =
             Arvo.Providers.Completion.complete_turn(
               [%{role: "user", content: "hi"}],
               [],
               stream_body: body,
               on_delta: fn t -> send(parent, {:delta, t}) end
             )

    assert result.content == "ab"
    assert result.streamed?
    assert_receive {:delta, "a"}
    assert_receive {:delta, "b"}
  end

  test "length_error classification is handoff-relevant signal" do
    msg = Arvo.Session.Compaction.length_error_message()
    assert Arvo.Providers.Completion.length_error_signal?(msg)
    assert msg =~ "/compact" or msg =~ "compact" or msg =~ "context"
  end

  test "agent streams multiple deltas before agent_end (no single post-hoc body)" do
    body = """
    data: {"choices":[{"delta":{"content":"one"}}]}

    data: {"choices":[{"delta":{"content":"two"}}]}

    data: [DONE]

    """

    parent = self()

    event_fun = fn
      {:message_delta, %{text: t}} -> send(parent, {:delta, t})
      {:agent_end, _} -> send(parent, :agent_end)
      _ -> :ok
    end

    assert {:ok, result} =
             Arvo.Agent.run(
               %{messages: [%{role: "user", content: "hi"}], cwd: "/tmp"},
               %{stream_body: body, model: "xai:test"},
               event_fun
             )

    assert result.stop_reason == :end_turn
    assert_receive {:delta, "one"}
    assert_receive {:delta, "two"}
    refute_receive {:delta, "onetwo"}
    assert_receive :agent_end
  end

  test "cancel during slow stream leaves no finished assistant on disk" do
    tmp = Path.join(System.tmp_dir!(), "arvo-stream-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    {:ok, path} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "slow stream"})

    complete_fun = fn _, _, config ->
      on_delta = Map.get(config, :on_delta, fn _ -> :ok end)
      on_delta.("partial")
      Process.sleep(10_000)
      {:ok, %{role: "assistant", content: "finished", tool_calls: [], streamed?: true}}
    end

    ctx = Arvo.TurnContext.build()

    {:ok, task} =
      Arvo.Session.start_turn(ctx, %{complete_fun: complete_fun}, fn _ -> :ok end)

    Process.sleep(30)
    :ok = Arvo.Session.cancel_turn()
    Process.sleep(30)
    refute Process.alive?(task.pid)

    entries = Arvo.Session.Store.read_all(path)
    refute Enum.any?(entries, &(&1["role"] == "assistant" && &1["content"] == "finished"))
  end

  test "tool-using turn still persists coherent tool rows when not cancelled" do
    tmp = Path.join(System.tmp_dir!(), "arvo-toolstream-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    {:ok, path} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "read it"})

    call_count = :atomics.new(1, signed: false)

    complete_fun = fn _, _, _ ->
      n = :atomics.add_get(call_count, 1, 1)

      if n == 1 do
        {:ok,
         %{
           role: "assistant",
           content: "",
           tool_calls: [%{id: "c1", name: "read", arguments: %{"path" => "a"}}],
           streamed?: true
         }}
      else
        {:ok, %{role: "assistant", content: "done", tool_calls: [], streamed?: true}}
      end
    end

    ctx = Arvo.TurnContext.build(tools: [Arvo.TestSupport.FakeReadTool])

    {:ok, _} =
      Arvo.Session.start_turn(ctx, %{complete_fun: complete_fun, max_turns: 5}, fn _ -> :ok end)

    assert {:ok, result} = Arvo.Session.await_turn(5_000)
    assert result.stop_reason == :end_turn

    entries = Arvo.Session.Store.read_all(path)
    assert Enum.any?(entries, &(&1["role"] == "tool"))
    assert Enum.any?(entries, &(&1["role"] == "assistant" && &1["content"] == "done"))
  end
end
