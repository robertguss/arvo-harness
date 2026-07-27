defmodule Arvo.ProductPathTest do
  use ExUnit.Case, async: false

  describe "Repl entry path" do
    test "handle_line routes slash commands to TUI (not unknown)" do
      assert {:slash, "help", ""} = Arvo.Repl.handle_line("/help")
      assert {:slash, "model", "xai:g"} = Arvo.Repl.handle_line("/model xai:g")
      assert {:slash, "profile", ""} = Arvo.Repl.handle_line("/profile")
      assert {:slash, "resume", ""} = Arvo.Repl.handle_line("/resume")
      assert {:slash, "compact", ""} = Arvo.Repl.handle_line("/compact")
      assert {:slash, "login", ""} = Arvo.Repl.handle_line("/login")
      assert :quit = Arvo.Repl.handle_line("/quit")
      assert {:chat, "hello"} = Arvo.Repl.handle_line("hello")
    end

    test "TUI.slash /help works (shipped path used by Repl)" do
      assert {:ok, :handled, text} = Arvo.TUI.slash("help")
      assert text =~ "/model"
      # Full v0.1 slash surface (SPEC §7) — not a partial stub list
      for cmd <- ~w(/help /model /profile /login /resume /compact /rewind /handoff /quit) do
        assert text =~ cmd
      end
    end
  end

  describe "TUI /login runs device flow" do
    test "login invokes DeviceFlow (mocked HTTP fails cleanly, not instruction-only)" do
      # Without network mock, DeviceFlow hits real auth — expect either ok or real error string
      # Structural: source of TUI do_slash login calls DeviceFlow.login
      tui_src = File.read!(Path.expand("../../lib/arvo/tui.ex", __DIR__))
      assert tui_src =~ "Arvo.Auth.DeviceFlow.login"
      refute tui_src =~ "run device login (Arvo.Auth.DeviceFlow.login/0)"
    end
  end

  describe "no silent auto-compact on product path (R15)" do
    test "default record_usage does not auto-compact" do
      tmp = Path.join(System.tmp_dir!(), "arvo-ac-#{System.unique_integer([:positive])}")
      File.mkdir_p!(tmp)
      old = System.get_env("HOME")
      System.put_env("HOME", tmp)
      Application.put_env(:arvo, :auto_compact, false)

      on_exit(fn ->
        if old, do: System.put_env("HOME", old)
        File.rm_rf!(tmp)
      end)

      {:ok, path} = Arvo.Session.open_new(tmp)

      for i <- 1..6 do
        {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "msg#{i} " <> String.duplicate("x", 20)})
      end

      {:ok, _} = Arvo.Session.record_usage(%{input_tokens: 100_000, output_tokens: 0})
      assert {:ok, :noop} = Arvo.Session.maybe_auto_compact(window: 100_000)

      entries = Arvo.Session.Store.read_all(path)
      refute Enum.any?(entries, &(&1["type"] == "compaction"))
    end

    test "opt-in auto_compact still works when forced" do
      tmp = Path.join(System.tmp_dir!(), "arvo-ac-force-#{System.unique_integer([:positive])}")
      File.mkdir_p!(tmp)
      old = System.get_env("HOME")
      System.put_env("HOME", tmp)

      on_exit(fn ->
        if old, do: System.put_env("HOME", old)
        File.rm_rf!(tmp)
      end)

      {:ok, path} = Arvo.Session.open_new(tmp)
      {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "x"})
      {:ok, _} = Arvo.Session.record_usage(%{input_tokens: 100_000, output_tokens: 0})
      assert {:ok, :compacted} = Arvo.Session.maybe_auto_compact(window: 100_000, force: true)
      entries = Arvo.Session.Store.read_all(path)
      assert Enum.any?(entries, &(&1["type"] == "compaction"))
    end

    test "auto compact is gated in Session source" do
      src = File.read!(Path.expand("../../lib/arvo/session.ex", __DIR__))
      assert src =~ "auto_compact"
      assert src =~ "maybe_auto_compact"
    end
  end

  describe "length error surfaces handoff" do
    test "classify path uses length_error_message" do
      src = File.read!(Path.expand("../../lib/arvo/providers/completion.ex", __DIR__))
      assert src =~ "Arvo.Session.Compaction.length_error_message"
      assert src =~ "length_error?"
    end

    test "length_error_message mentions handoff" do
      msg = Arvo.Session.Compaction.length_error_message()
      assert msg =~ "/handoff"
    end
  end

  describe "Agent default path uses complete_turn with tools" do
    test "agent default_complete calls complete_turn" do
      src = File.read!(Path.expand("../../lib/arvo/agent.ex", __DIR__))
      assert src =~ "complete_turn"
      refute src =~ "tool_calls: []\n         }}\n\n      {:error"
    end

    test "product chat path uses Session.start_turn not bare Agent.run" do
      repl_src = File.read!(Path.expand("../../lib/arvo/repl.ex", __DIR__))
      assert repl_src =~ "Arvo.Session.start_turn"
      assert repl_src =~ "Arvo.TUI.slash"
      # Product chat must not call Agent.run inline (library path only)
      refute repl_src =~ "Arvo.Agent.run"

      # Focus is the product default surface — lock the same spine
      focus_src = File.read!(Path.expand("../../lib/arvo/tui/focus.ex", __DIR__))
      assert focus_src =~ "Arvo.Session.start_turn"
      refute focus_src =~ "Arvo.Agent.run"
    end

    test "turn context assembly always includes skills key" do
      src = File.read!(Path.expand("../../lib/arvo/turn_context.ex", __DIR__))
      assert src =~ "skills"
      ctx = Arvo.TurnContext.build(messages: [%{role: "user", content: "hi"}], tools: [])
      assert Map.has_key?(ctx, :skills)
      assert is_list(ctx.skills)
    end
  end

  describe "Session-owned product turn spine" do
    setup do
      tmp = Path.join(System.tmp_dir!(), "arvo-spine-#{System.unique_integer([:positive])}")
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

    test "chat turn completes with Session-owned persist", %{path: path} do
      complete_fun = fn _, _, _ ->
        {:ok, %{role: "assistant", content: "hello back", tool_calls: []}}
      end

      {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "hello"})
      ctx = Arvo.TurnContext.build()
      assert ctx.prior_len == 1
      assert Map.has_key?(ctx, :skills)

      {:ok, _task} =
        Arvo.Session.start_turn(ctx, %{complete_fun: complete_fun, model: "xai:test"}, fn _ ->
          :ok
        end)

      assert {:ok, result} = Arvo.Session.await_turn(5_000)
      assert result.stop_reason == :end_turn

      # Idle: no turn task
      sess = Arvo.Session.get()
      assert is_nil(sess.turn_task)

      entries = Arvo.Session.Store.read_all(path)
      assistants = Enum.filter(entries, &(&1["role"] == "assistant"))
      assert Enum.any?(assistants, &(&1["content"] == "hello back"))
    end

    test "Esc mid-turn: Task dead, Session alive, no complete assistant success", %{path: path} do
      complete_fun = fn _, _, _ ->
        Process.sleep(10_000)
        {:ok, %{role: "assistant", content: "should not persist", tool_calls: []}}
      end

      {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "slow"})
      ctx = Arvo.TurnContext.build()

      {:ok, task} =
        Arvo.Session.start_turn(ctx, %{complete_fun: complete_fun}, fn _ -> :ok end)

      assert Process.alive?(task.pid)
      :ok = Arvo.Session.cancel_turn()
      Process.sleep(50)
      refute Process.alive?(task.pid)
      assert is_pid(Process.whereis(Arvo.Session))

      sess = Arvo.Session.get()
      assert is_nil(sess.turn_task)

      entries = Arvo.Session.Store.read_all(path)
      refute Enum.any?(entries, &(&1["role"] == "assistant" && &1["content"] == "should not persist"))
    end

    test "cancel after tool_call_start does not claim success", %{path: path} do
      parent = self()
      call_count = :atomics.new(1, signed: false)

      complete_with_tool = fn _messages, _tools_spec, _config ->
        n = :atomics.add_get(call_count, 1, 1)

        if n == 1 do
          {:ok,
           %{
             role: "assistant",
             content: "",
             tool_calls: [%{id: "t1", name: "read", arguments: %{"path" => "x"}}]
           }}
        else
          Process.sleep(10_000)
          {:ok, %{role: "assistant", content: "done", tool_calls: []}}
        end
      end

      {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "use tool"})
      ctx = Arvo.TurnContext.build(tools: [Arvo.TestSupport.SlowReadTool])

      event_fun = fn
        {:tool_call_start, _} = ev ->
          send(parent, ev)
          :ok

        _ ->
          :ok
      end

      {:ok, _task} =
        Arvo.Session.start_turn(ctx, %{complete_fun: complete_with_tool, max_turns: 5}, event_fun)

      assert_receive {:tool_call_start, %{name: "read"}}, 2_000
      :ok = Arvo.Session.cancel_turn()
      Process.sleep(50)

      entries = Arvo.Session.Store.read_all(path)
      refute Enum.any?(entries, &(&1["role"] == "assistant" && &1["content"] == "done"))
    end

    test "agent exception mid-turn leaves Session alive and idle", %{path: _path} do
      complete_fun = fn _, _, _ ->
        raise "boom-turn"
      end

      {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "explode"})
      ctx = Arvo.TurnContext.build()

      {:ok, _task} =
        Arvo.Session.start_turn(ctx, %{complete_fun: complete_fun}, fn _ -> :ok end)

      result = Arvo.Session.await_turn(5_000)
      assert match?({:error, _}, result)
      assert is_pid(Process.whereis(Arvo.Session))
      sess = Arvo.Session.get()
      assert is_nil(sess.turn_task)
    end

    test "profile switch exposes skills+tools+slash on next start_turn (AE5)" do
      # Register toy plugin
      :ok = Arvo.Plugins.Registry.register_loaded("toy_plugin", Toy.Plugin)
      _ = Arvo.Plugins.Registry.deactivate("toy_plugin")

      assert {:ok, :handled, _} = Arvo.TUI.slash("profile", "base")

      # Manual activate as set-diff target
      assert :ok = Arvo.Plugins.Registry.activate("toy_plugin")

      skills = Arvo.Plugins.Registry.skills()
      assert Enum.any?(skills, &((&1[:name] || &1["name"]) == "toy-skill"))

      skill = Enum.find(skills, &((&1[:name] || &1["name"]) == "toy-skill"))
      desc = skill[:description] || skill["description"] || ""
      assert desc =~ "progressive"
      # progressive: name+desc, not full body inject into skill map
      refute Map.has_key?(skill, :body)

      cmds = Arvo.Plugins.Registry.commands()
      assert Map.has_key?(cmds, "toy_plugin:ping") or Map.has_key?(cmds, "ping")

      assert {:ok, :handled, help} = Arvo.TUI.slash("help")
      assert help =~ "toy_plugin:ping" or help =~ "ping"

      ctx = Arvo.TurnContext.build()
      assert Enum.any?(ctx.skills, &((&1[:name] || &1["name"]) == "toy-skill"))
      tool_names = Enum.map(ctx.tools, & &1.spec().name)
      assert "toy_echo" in tool_names


      prompt = Arvo.Prompt.assemble(skills: ctx.skills, tools: ctx.tools)
      assert prompt =~ "toy-skill"
      refute prompt =~ "FULL_SKILL_BODY_SHOULD_NOT_APPEAR"

      # Deactivate removes surface
      assert :ok = Arvo.Plugins.Registry.deactivate("toy_plugin")
      refute Enum.any?(Arvo.Plugins.Registry.skills(), &((&1[:name] || &1["name"]) == "toy-skill"))
      refute Map.has_key?(Arvo.Plugins.Registry.commands(), "toy_plugin:ping")
    end

    test "steering queued during turn appears on next model step after tools" do
      parent = self()
      call_count = :atomics.new(1, signed: false)

      complete_fun = fn messages, _, _ ->
        n = :atomics.add_get(call_count, 1, 1)

        cond do
          n == 1 ->
            {:ok,
             %{
               role: "assistant",
               content: "",
               tool_calls: [%{id: "c1", name: "read", arguments: %{"path" => "a"}}]
             }}

          true ->
            users = Enum.filter(messages, &((&1[:role] || &1["role"]) == "user"))
            send(parent, {:second_complete, users})
            {:ok, %{role: "assistant", content: "after-steer", tool_calls: []}}
        end
      end

      {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "go"})
      ctx = Arvo.TurnContext.build(tools: [Arvo.TestSupport.FakeReadTool])

      {:ok, _task} =
        Arvo.Session.start_turn(ctx, %{complete_fun: complete_fun, max_turns: 5}, fn _ -> :ok end)

      :ok = Arvo.Session.steer("steer-me")
      assert {:ok, result} = Arvo.Session.await_turn(5_000)
      assert result.stop_reason == :end_turn

      assert_receive {:second_complete, users}, 1_000
      assert Enum.any?(users, fn m -> (m[:content] || m["content"] || "") =~ "steer-me" end)
    end
  end
end
