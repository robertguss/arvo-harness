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
    complete_fun = fn _, _, _ ->
      Process.sleep(10_000)
      {:ok, %{role: "assistant", content: "x", tool_calls: []}}
    end

    {:ok, task} =
      Arvo.Session.start_turn(
        %{messages: [%{role: "user", content: "slow"}], cwd: File.cwd!()},
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
