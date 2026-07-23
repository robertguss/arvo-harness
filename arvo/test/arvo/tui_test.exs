defmodule Arvo.TUITest do
  use ExUnit.Case, async: false

  test "state derives only from events — no agent logic" do
    :ok = Arvo.TUI.handle_event({:agent_start, %{}})
    st = Arvo.TUI.state()
    assert st.status == :running
    assert st.spinner

    :ok = Arvo.TUI.handle_event({:message_delta, %{text: "hi"}})
    st = Arvo.TUI.state()
    assert st.buffer == "hi"
    assert st.streaming

    :ok = Arvo.TUI.handle_event({:tool_call_start, %{name: "bash"}})
    st = Arvo.TUI.state()
    assert st.tool_name == "bash"
    assert st.spinner

    :ok = Arvo.TUI.handle_event({:agent_end, %{}})
    st = Arvo.TUI.state()
    assert st.status == :idle
  end

  test "slash /model /help /quit" do
    assert {:ok, :handled, help} = Arvo.TUI.slash("help")
    assert help =~ "/model"
    assert help =~ "/profile"
    assert help =~ "/login"
    assert help =~ "/resume"
    assert help =~ "/compact"
    assert help =~ "/quit"

    assert {:ok, :handled, _} = Arvo.TUI.slash("model", "xai:grok-test")
    assert Arvo.TUI.model() == "xai:grok-test"

    assert {:ok, :handled, m} = Arvo.TUI.slash("model")
    assert m =~ "xai:grok-test"

    assert {:ok, :quit, _} = Arvo.TUI.slash("quit")
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

    :ok = Arvo.TUI.handle_event({:agent_start, %{}})
    assert :cancelled = Arvo.TUI.key(:esc)
    Process.sleep(30)
    refute Process.alive?(task.pid)
    assert Process.alive?(Process.whereis(Arvo.Supervisor))
  end

  test "parse commands" do
    assert Arvo.TUI.Commands.parse("/model xai:g") == {:command, "model", "xai:g"}
    assert Arvo.TUI.Commands.parse("hello") == {:text, "hello"}
  end
end
