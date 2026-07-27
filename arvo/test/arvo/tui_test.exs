defmodule Arvo.TUITest do
  use ExUnit.Case, async: false

  test "state derives only from events — no agent logic" do
    :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})
    st = Arvo.TUI.state()
    assert st.status == :running
    assert st.spinner

    :ok = Arvo.TUI.handle_event_sync({:message_delta, %{text: "hi"}})
    st = Arvo.TUI.state()
    assert st.buffer == "hi"
    assert st.streaming

    :ok = Arvo.TUI.handle_event_sync({:tool_call_start, %{name: "bash"}})
    st = Arvo.TUI.state()
    assert st.tool_name == "bash"
    assert st.spinner
    assert Enum.any?(st.transcript, &(&1.kind == :tool && &1.name == "bash"))

    :ok = Arvo.TUI.handle_event_sync({:agent_end, %{}})
    st = Arvo.TUI.state()
    assert st.status == :idle
  end

  test "tool_end folds tool line; agent_error is loud idle chrome" do
    :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})
    :ok = Arvo.TUI.handle_event_sync({:tool_call_start, %{name: "read"}})
    :ok = Arvo.TUI.handle_event_sync({:tool_call_end, %{name: "read", is_error: false, text: "ok"}})
    st = Arvo.TUI.state()
    tool = Enum.find(st.transcript, &(&1.kind == :tool && &1.name == "read"))
    assert tool.folded == true
    assert tool.text == "ok"

    :ok = Arvo.TUI.handle_event_sync({:agent_error, %{error: "boom"}})
    st = Arvo.TUI.state()
    assert st.status == :idle
    assert st.last_error == "boom"
    assert st.spinner == false
  end

  test "message_delta accumulates without requiring full redraw" do
    :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})
    :ok = Arvo.TUI.handle_event_sync({:message_delta, %{text: "a"}})
    :ok = Arvo.TUI.handle_event_sync({:message_delta, %{text: "b"}})
    st = Arvo.TUI.state()
    assert st.buffer == "ab"
    assert st.streaming
  end

  test "slash /model /help /quit" do
    assert {:ok, :handled, help} = Arvo.TUI.slash("help")
    assert help =~ "/model"
    assert help =~ "/profile"
    assert help =~ "/login"
    assert help =~ "/resume"
    assert help =~ "/compact"
    assert help =~ "/quit"
    assert help =~ "Esc"

    assert {:ok, :handled, _} = Arvo.TUI.slash("model", "xai:grok-test")
    assert Arvo.TUI.model() == "xai:grok-test"

    assert {:ok, :handled, m} = Arvo.TUI.slash("model")
    assert m =~ "xai:grok-test"

    assert {:ok, :quit, _} = Arvo.TUI.slash("quit")
  end

  test "Focus render has ghost strip, input, footer" do
    st = %{
      model: "xai:g",
      profile: "base",
      tokens: %{cumulative: 10, window: 100},
      status: :idle,
      transcript: [%{kind: :user, text: "hi"}],
      buffer: "",
      streaming: false,
      input: "hello",
      last_error: nil
    }

    frame = Arvo.TUI.Render.frame(st, width: 60, height: 12)
    assert frame =~ "xai:g"
    assert frame =~ "base"
    assert frame =~ "ctx"
    assert frame =~ "›" or frame =~ "hello"
    assert frame =~ "Esc"
    assert frame =~ "Enter"
    # Stable height so overwrite paints (no clear_screen) do not leave ghosts
    assert length(String.split(frame, "\n")) == 12
  end

  test "Focus raw loop does not clear_screen on every poll (jitter regression)" do
    src = File.read!(Path.expand("../../lib/arvo/tui/focus.ex", __DIR__))
    # Only the initial alt-screen setup may clear; the loop paints by overwrite.
    clears = Regex.scan(~r/Termite\.Screen\.clear_screen/, src)
    assert length(clears) == 1
    assert src =~ "paint_frame"
    assert src =~ "frame == last_frame"
  end

  test "system/slash multi-line text wraps instead of truncating to one width line" do
    help = """
    Commands:
      /help              this help
      /model [spec]      show or set model
      /quit              exit
    Keys (Focus): Enter send · Esc cancel
    """

    st = %{
      model: "xai:g",
      profile: "base",
      tokens: %{cumulative: 0, window: 100},
      status: :idle,
      transcript: [%{kind: :system, text: help}],
      buffer: "",
      streaming: false,
      input: "",
      last_error: nil
    }

    frame = Arvo.TUI.Render.frame(st, width: 40, height: 20)
    # Prior bug: only first ~40 chars ("Commands:\\n  /help…") survived as one line.
    assert frame =~ "/model"
    assert frame =~ "/quit"
    assert frame =~ "Esc"

    lines = Arvo.TUI.Render.wrap_text(help, 40)
    assert length(lines) > 1
    assert Enum.any?(lines, &String.contains?(&1, "/model"))
  end

  test "Focus.run halts VM on quit when enabled (injectable)" do
    test_pid = self()
    Application.put_env(:arvo, :halt_on_focus_quit, true)
    Application.put_env(:arvo, :focus_halt_fun, fn code -> send(test_pid, {:halt, code}) end)

    on_exit(fn ->
      Application.put_env(:arvo, :halt_on_focus_quit, false)
      Application.delete_env(:arvo, :focus_halt_fun)
    end)

    {:ok, device} = StringIO.open("quit\n")

    assert :ok = Arvo.TUI.Focus.run(mode: :line, device: device)
    assert_receive {:halt, 0}, 500
  end

  test "boot/source contract: default interactive path is Focus not Repl dual-start" do
    app = File.read!(Path.expand("../../lib/arvo/application.ex", __DIR__))
    assert app =~ "Arvo.TUI.Focus"
    assert app =~ "start_focus"
    # Repl is fallback only — not started when Focus is default
    assert app =~ "start_repl"
    refute app =~ "maybe_start_repl"
  end

  test "/login runs DeviceFlow (mocked, outside GenServer)" do
    http = fn
      "https://auth.x.ai/oauth2/device/code", _ ->
        {:ok,
         %{
           status: 200,
           body: %{
             "device_code" => "dc",
             "user_code" => "AA-BB",
             "verification_uri" => "https://auth.x.ai/device",
             "expires_in" => 60,
             "interval" => 0
           }
         }}

      "https://auth.x.ai/oauth2/token", _ ->
        {:ok,
         %{
           status: 200,
           body: %{
             "access_token" => "a",
             "refresh_token" => "r",
             "expires_in" => 3600
           }
         }}
    end

    tmp = Path.join(System.tmp_dir!(), "arvo-login-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    assert {:ok, :handled, msg} =
             Arvo.TUI.run_login(http: http, sleep: fn _ -> :ok end, notify: fn _ -> :ok end)

    assert msg =~ "login ok"
    assert Arvo.Auth.Store.get("grok")["access_token"] == "a"
  end

  test "Esc mid-turn cancels Session task" do
    tmp = Path.join(System.tmp_dir!(), "arvo-esc-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    {:ok, _path} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "slow"})

    complete_fun = fn _, _, _ ->
      Process.sleep(10_000)
      {:ok, %{role: "assistant", content: "x", tool_calls: []}}
    end

    ctx = Arvo.TurnContext.build()

    {:ok, task} =
      Arvo.Session.start_turn(
        ctx,
        %{complete_fun: complete_fun},
        fn ev -> Arvo.TUI.handle_event(ev) end
      )

    :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})
    assert :cancelled = Arvo.TUI.key(:esc)
    Process.sleep(30)
    refute Process.alive?(task.pid)
    assert Process.alive?(Process.whereis(Arvo.Supervisor))
    st = Arvo.TUI.state()
    assert st.status == :idle
    assert st.spinner == false
  end

  test "parse commands" do
    assert Arvo.TUI.Commands.parse("/model xai:g") == {:command, "model", "xai:g"}
    assert Arvo.TUI.Commands.parse("hello") == {:text, "hello"}
  end
end
