defmodule Arvo.WarmTest do
  use ExUnit.Case, async: false

  alias Arvo.Session.Warm

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-warm-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)
    Application.put_env(:arvo, :progressive_attention, true)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    {:ok, _} = Arvo.Session.open_new(tmp)
    %{tmp: tmp}
  end

  test "update_from_tool tracks paths and errors" do
    warm = Warm.empty()

    warm =
      Warm.update_from_tool(warm, %{
        tool: "read",
        args: %{"path" => "lib/a.ex"},
        is_error: false,
        text: "defmodule A"
      })

    warm =
      Warm.update_from_tool(warm, %{
        tool: "bash",
        args: %{"command" => "mix test"},
        is_error: true,
        text: "1 failure"
      })

    assert "lib/a.ex" in warm["paths"]
    assert warm["last_error"] =~ "failure"
    assert length(warm["last_commands"]) == 1
  end

  test "goal only when product-valid writer sets it; honesty when unknown" do
    warm = Warm.empty()
    assert warm["goal_known"] == false

    warm = Warm.set_goal(warm, "fix the flaky test")
    assert warm["goal_known"] == true
    assert warm["goal"] =~ "flaky"

    packet = Warm.to_packet_fields(Warm.empty())
    assert packet["goal_known"] == false
    assert packet["goal"] == nil
  end

  test "session records user line as goal; tools update warm; TurnContext injects", %{tmp: _tmp} do
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "implement cold store"})
    warm = Arvo.Session.warm()
    assert warm["goal_known"] == true
    assert warm["goal"] =~ "cold store"

    _ =
      Arvo.Session.project_tool_result(
        "bash",
        %{"command" => "ls"},
        String.duplicate("file\n", 2000),
        false
      )

    warm = Arvo.Session.warm()
    assert is_list(warm["paths"]) or warm["last_commands"] != []

    ctx = Arvo.TurnContext.build()
    assert Enum.any?(ctx.messages, fn m ->
             c = m[:content] || m["content"] || ""
             c =~ "[warm work-delta]" and c =~ "cold store"
           end)
  end

  test "handoff packet uses live warm paths and goal honesty" do
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "ship progressive attention"})

    _ =
      Arvo.Session.project_tool_result(
        "read",
        %{"path" => "lib/foo.ex"},
        "defmodule Foo\n" <> String.duplicate("x", 100),
        false
      )

    packet = Arvo.Session.Handoff.build_packet()
    assert packet["goal_known"] == true
    assert packet["goal"] =~ "progressive"
    assert "lib/foo.ex" in packet["paths"] or packet["paths"] != []
  end

  test "goal unknown packet does not invent goal on rehydrate" do
    # Clear goal
    {:ok, _} = Arvo.Session.set_warm_goal(nil)
    packet = Arvo.Session.Handoff.build_packet()
    assert packet["goal_known"] == false
    assert is_nil(packet["goal"])

    blob = Arvo.Session.Handoff.packet_blob(packet)
    assert blob =~ "goal_known: false"
    assert blob =~ "(unknown"

    warm = Arvo.Session.Warm.from_packet(packet)
    assert warm["goal_known"] == false
    assert is_nil(warm["goal"]) or warm["goal"] == ""
  end
end
