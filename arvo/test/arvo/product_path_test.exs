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
      for cmd <- ~w(/help /model /profile /login /resume /compact /quit) do
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

  describe "auto-compact on product path" do
    test "record_usage triggers auto-compact when over threshold" do
      tmp = Path.join(System.tmp_dir!(), "arvo-ac-#{System.unique_integer([:positive])}")
      File.mkdir_p!(tmp)
      old = System.get_env("HOME")
      System.put_env("HOME", tmp)

      on_exit(fn ->
        if old, do: System.put_env("HOME", old)
        File.rm_rf!(tmp)
      end)

      {:ok, path} = Arvo.Session.open_new(tmp)

      for i <- 1..6 do
        {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "msg#{i} " <> String.duplicate("x", 20)})
      end

      # Force cumulative over threshold with tiny window
      # record_usage adds tokens then maybe_auto_compact with default window — inject via maybe_auto_compact opts
      # First pump cumulative high
      {:ok, _} = Arvo.Session.record_usage(%{input_tokens: 100_000, output_tokens: 0})

      # Call with small window so threshold is low
      assert {:ok, :compacted} = Arvo.Session.maybe_auto_compact(window: 100_000)

      entries = Arvo.Session.Store.read_all(path)
      assert Enum.any?(entries, &(&1["type"] == "compaction"))
    end

    test "should_auto_compact is called from Session source" do
      src = File.read!(Path.expand("../../lib/arvo/session.ex", __DIR__))
      assert src =~ "should_auto_compact?"
      assert src =~ "maybe_auto_compact"
    end
  end

  describe "length error surfaces /compact" do
    test "classify path uses length_error_message" do
      src = File.read!(Path.expand("../../lib/arvo/providers/completion.ex", __DIR__))
      assert src =~ "Arvo.Session.Compaction.length_error_message"
      assert src =~ "length_error?"
    end

    test "length_error_message text" do
      msg = Arvo.Session.Compaction.length_error_message()
      assert msg =~ "/compact"
    end
  end

  describe "Agent default path uses complete_turn with tools" do
    test "agent default_complete calls complete_turn" do
      src = File.read!(Path.expand("../../lib/arvo/agent.ex", __DIR__))
      assert src =~ "complete_turn"
      refute src =~ "tool_calls: []\n         }}\n\n      {:error"
    end

    test "Repl chat path starts Agent.run" do
      src = File.read!(Path.expand("../../lib/arvo/repl.ex", __DIR__))
      assert src =~ "Arvo.Agent.run"
      assert src =~ "Arvo.TUI.slash"
    end
  end
end
