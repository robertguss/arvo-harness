defmodule Arvo.TUITest do
  use ExUnit.Case, async: false

  setup do
    # Shared named TUI GenServer — restore ambient attention so off-tests don't leak
    :ok = Arvo.TUI.put_attention_mode("on")
    _ = Arvo.TUI.state()
    :ok
  end

  test "state derives only from events — no agent logic" do
    :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})
    st = Arvo.TUI.state()
    assert st.status == :running
    assert st.spinner

    :ok = Arvo.TUI.handle_event_sync({:message_delta, %{text: "hi"}})
    st = Arvo.TUI.state()
    assert st.buffer == "hi"
    assert st.streaming

    :ok =
      Arvo.TUI.handle_event_sync(
        {:tool_call_start, %{name: "bash", arguments: %{command: "echo hi"}}}
      )

    st = Arvo.TUI.state()
    assert st.tool_name == "bash"
    assert st.spinner
    assert Enum.any?(st.transcript, &(&1.kind == :activity && &1.name == "bash"))

    :ok = Arvo.TUI.handle_event_sync({:agent_end, %{}})
    st = Arvo.TUI.state()
    assert st.status == :idle
  end

  test "tool_end updates activity line; agent_error is loud idle chrome" do
    :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})

    :ok =
      Arvo.TUI.handle_event_sync({:tool_call_start, %{name: "read", arguments: %{path: "x.ex"}}})

    :ok =
      Arvo.TUI.handle_event_sync({:tool_call_end, %{name: "read", is_error: false, text: "ok"}})

    st = Arvo.TUI.state()

    act =
      st.transcript
      |> Enum.filter(&(&1.kind == :activity && &1.name == "read" && &1.detail == "ok"))
      |> List.last()

    assert act
    assert act.status == :ok
    assert act.summary =~ "read"
    assert act.summary =~ "x.ex"
    # Human body clean — chrome is adjacent :attention_access (R13)
    assert act.detail == "ok"
    assert act.expanded == false

    access =
      st.transcript
      |> Enum.filter(&(&1.kind == :attention_access && &1.tool == "read" && &1.outcome == :full_hot))
      |> List.last()

    assert access
    assert access.label =~ "[model:full]" or access.detail =~ "[model:full]"

    :ok = Arvo.TUI.handle_event_sync({:agent_error, %{error: "boom"}})
    st = Arvo.TUI.state()
    assert st.status == :idle
    assert st.last_error == "boom"
    assert st.spinner == false
  end

  test "dual-view stub shows model pane with stub text" do
    # Characterization: stub projection → one access chrome child with dual-view body (R13/R19)
    :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})

    :ok =
      Arvo.TUI.handle_event_sync({:tool_call_start, %{name: "bash", arguments: %{command: "ls"}}})

    :ok =
      Arvo.TUI.handle_event_sync({
        :tool_call_end,
        %{
          name: "bash",
          is_error: false,
          text: String.duplicate("full log\n", 50),
          model_text: "[cold:abc123 tool=bash bytes=900]",
          attention_action: :stub,
          cold_id: "abc123",
          event_id: "evt-stub-1",
          attention_secondary: [:store]
        }
      })

    st = Arvo.TUI.state()

    act =
      st.transcript
      |> Enum.filter(&(&1.kind == :activity && &1.name == "bash"))
      |> List.last()

    assert act
    assert act.summary =~ "ls"
    assert act.detail =~ "full log"
    # No competing dual-view taxonomy on activity body
    refute act.detail =~ "[model:stub"
    refute act.detail =~ "dual-view"

    access =
      st.transcript
      |> Enum.filter(&(&1.kind == :attention_access))
      |> List.last()

    assert access
    assert access.outcome == :stub
    assert access.cold_id == "abc123"
    assert access.event_id == "evt-stub-1"
    assert access.detail =~ "[model:stub"
    assert access.detail =~ "cold:abc123"
    assert access.detail =~ "model saw"
    assert access.detail =~ "[cold:abc123"
    assert access.summary =~ "stub"
    assert :store in access.secondary or access.summary =~ "store"
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
    assert help =~ "/new"
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

  test "assistant and user messages wrap instead of single-line slice cutoff" do
    long =
      "I'll scan the project layout and key docs to summarize the repo. " <>
        "Gathering a bit more from README and mix.exs before I answer fully."

    st = %{
      model: "xai:g",
      profile: "base",
      tokens: %{cumulative: 0, window: 100},
      status: :idle,
      transcript: [
        %{kind: :user, text: "tell me about this repo in some detail please"},
        %{kind: :assistant, text: long}
      ],
      buffer: "",
      streaming: false,
      input: "",
      last_error: nil
    }

    frame = Arvo.TUI.Render.frame(st, width: 40, height: 24)
    # Prior bug: String.slice to width-5 dropped everything after the first line.
    # Soft-wrap keeps whole words; content still present across multiple rows.
    assert frame =~ "Gathering"
    assert frame =~ "a bit more"
    assert frame =~ "README"
    assert frame =~ "you"
    assert frame =~ "arvo"
  end

  test "activity entries are step cards; long detail collapses with more-lines cue" do
    # >8 lines so collapsed path shows short preview + more cue (R11/AE5)
    tool_out =
      Enum.map_join(1..12, "\n", fn i ->
        case i do
          1 -> "total 7144"
          2 -> "drwxrwxr-x 12 rob rob    4096 Jul 28 ."
          3 -> "-rw-rw-r--  1 rob rob    1234 Jul 28 early.ex"
          10 -> "-rw-rw-r--  1 rob rob    5678 Jul 28 buried-line.md"
          _ -> "more line #{i}"
        end
      end)

    st = %{
      model: "xai:g",
      profile: "base",
      tokens: %{cumulative: 0, window: 100},
      status: :idle,
      transcript: [
        %{
          kind: :activity,
          name: "bash",
          summary: "bash · ls -la",
          status: :ok,
          detail: tool_out <> "\n [model:full]",
          expanded: false
        }
      ],
      buffer: "",
      streaming: false,
      input: "",
      last_error: nil
    }

    frame = Arvo.TUI.Render.frame(st, width: 60, height: 24)
    # AE4: tool step header
    assert frame =~ "bash · ls -la"
    # Collapsed: short preview + more-lines cue; buried line hidden
    assert frame =~ "more lines"
    refute frame =~ "buried-line.md"

    st2 = put_in(st, [:transcript, Access.at(0), :expanded], true)
    frame2 = Arvo.TUI.Render.frame(st2, width: 60, height: 24)
    assert frame2 =~ "buried-line.md"
    assert frame2 =~ "early.ex"
  end

  test "running activity shows live chrome; aborted assistant labeled" do
    st = %{
      model: "xai:g",
      profile: "base",
      tokens: %{cumulative: 0, window: 100},
      status: :running,
      transcript: [
        %{
          kind: :activity,
          name: "read",
          summary: "read · lib/x.ex",
          status: :running,
          detail: nil,
          expanded: false
        },
        %{kind: :assistant, text: "partial answer", aborted: true}
      ],
      buffer: "",
      streaming: false,
      input: "",
      last_error: nil
    }

    frame = Arvo.TUI.Render.frame(st, width: 60, height: 16)
    assert frame =~ "read · lib/x.ex"
    assert frame =~ "running"
    assert frame =~ "aborted"
  end

  test "thought header hierarchy persists after completion" do
    st = %{
      model: "xai:g",
      profile: "base",
      tokens: %{cumulative: 0, window: 100},
      status: :idle,
      transcript: [
        %{
          kind: :thought,
          text: "I should inspect the session tree first.",
          started_at: 0,
          ended_at: 1500,
          expanded: true,
          live: false
        }
      ],
      buffer: "",
      streaming: false,
      input: "",
      last_error: nil
    }

    frame = Arvo.TUI.Render.frame(st, width: 60, height: 12)
    assert frame =~ "Thought"
    assert frame =~ "session tree"
  end

  test "transcript scroll reveals older lines above the live tail" do
    entries =
      for i <- 1..20 do
        %{kind: :system, text: "line-#{i}-marker"}
      end

    st = %{
      model: "xai:g",
      profile: "base",
      tokens: %{cumulative: 0, window: 100},
      status: :idle,
      transcript: entries,
      buffer: "",
      streaming: false,
      input: "",
      last_error: nil
    }

    # height 12 → body_h = 7; tail should show late markers
    tail = Arvo.TUI.Render.frame(st, width: 40, height: 12, scroll: 0)
    assert tail =~ "line-20-marker"
    refute tail =~ "line-1-marker"

    older = Arvo.TUI.Render.frame(st, width: 40, height: 12, scroll: 15)
    assert older =~ "line-1-marker" or older =~ "line-2-marker"
    refute older =~ "line-20-marker"
  end

  test "streaming assistant buffer wraps with cursor on last line" do
    st = %{
      model: "xai:g",
      profile: "base",
      tokens: %{cumulative: 0, window: 100},
      status: :running,
      transcript: [],
      buffer: String.duplicate("word ", 30),
      streaming: true,
      input: "",
      last_error: nil
    }

    frame = Arvo.TUI.Render.frame(st, width: 30, height: 16)
    assert frame =~ "arvo"
    assert frame =~ "word"
    assert frame =~ "▍"
    # More than one body line of content (not width-sliced to a single row).
    body_hits =
      frame
      |> String.split("\n")
      |> Enum.count(&String.contains?(&1, "word"))

    assert body_hits >= 2
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

  test "thinking events create collapsible Thought row" do
    :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})
    :ok = Arvo.TUI.handle_event_sync({:thinking_start, %{}})
    :ok = Arvo.TUI.handle_event_sync({:thinking_delta, %{text: "I should list files"}})
    st = Arvo.TUI.state()
    th = st.transcript |> Enum.filter(&(&1.kind == :thought)) |> List.last()
    assert th.live
    assert th.expanded
    assert th.text =~ "list files"

    :ok = Arvo.TUI.handle_event_sync({:thinking_end, %{}})
    st = Arvo.TUI.state()
    th = st.transcript |> Enum.filter(&(&1.kind == :thought)) |> List.last()
    assert th.live == false
    # Reasoning stays expanded so it remains in scrollback after the turn
    assert th.expanded == true
    assert is_integer(th.ended_at)

    frame = Arvo.TUI.Render.frame(st, width: 60, height: 16)
    assert frame =~ "Thought"
    assert frame =~ "list files"
  end

  test "Ctrl+E expands all focusable rows" do
    :ok = Arvo.TUI.handle_event_sync({:thinking_start, %{}})
    :ok = Arvo.TUI.handle_event_sync({:thinking_delta, %{text: "reason"}})
    :ok = Arvo.TUI.handle_event_sync({:thinking_end, %{}})

    :ok =
      Arvo.TUI.handle_event_sync({:tool_call_start, %{name: "bash", arguments: %{command: "ls"}}})

    :ok =
      Arvo.TUI.handle_event_sync(
        {:tool_call_end, %{name: "bash", text: "a\nb\n", is_error: false}}
      )

    {:ok, st} = Arvo.TUI.handle_key(Arvo.TUI.state(), :ctrl_e)
    assert st.expand_all == true

    assert Enum.all?(st.transcript, fn
             %{kind: k, expanded: e} when k in [:thought, :activity] -> e
             _ -> true
           end)
  end

  test "slash palette renders command descriptions" do
    st = %{
      model: "xai:g",
      profile: "base",
      tokens: %{cumulative: 0, window: 100},
      status: :idle,
      transcript: [],
      buffer: "",
      streaming: false,
      input: "/he",
      palette: %{query: "he", selected: 0},
      last_error: nil
    }

    frame = Arvo.TUI.Render.frame(st, width: 70, height: 16)
    assert frame =~ "/help"
    assert frame =~ "Show commands" or frame =~ "commands"
  end

  test "/new opens a fresh session and clears transcript" do
    tmp = Path.join(System.tmp_dir!(), "arvo-new-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    {:ok, path1} = Arvo.Session.open_new(tmp)
    :ok = Arvo.TUI.append_user("old message")
    :ok = Arvo.TUI.append_system("noise")
    st_before = Arvo.TUI.state()
    assert length(st_before.transcript) >= 2

    assert {:ok, :handled, msg} = Arvo.TUI.slash("new")
    assert msg =~ "new session"
    refute msg =~ Path.basename(path1)

    st = Arvo.TUI.state()
    assert st.status == :idle
    assert st.buffer == ""
    assert st.streaming == false
    # Fresh pane: only the system marker for the new session
    assert length(st.transcript) == 1
    assert hd(st.transcript).kind == :system
    assert hd(st.transcript).text =~ "new session"

    sess = Arvo.Session.get()
    assert is_binary(sess.path)
    assert sess.path != path1
    assert File.exists?(sess.path)
  end

  test "/tree in help and catalog" do
    assert {:ok, :handled, help} = Arvo.TUI.slash("help")
    assert help =~ "/tree"
    assert help =~ "legacy" or help =~ "prefer /tree"

    names = Enum.map(Arvo.TUI.SlashMenu.catalog(), &elem(&1, 0))
    assert "tree" in names
  end

  test "Session Tree chrome renders node previews" do
    nodes = [
      %{
        id: "a",
        parent_id: nil,
        kind: :user,
        preview: "hello tree world",
        jumpable?: true,
        head?: false,
        tip?: false,
        aborted?: false
      },
      %{
        id: "b",
        parent_id: "a",
        kind: :assistant,
        preview: "reply here",
        jumpable?: true,
        head?: true,
        tip?: true,
        aborted?: false
      },
      %{
        id: "c",
        parent_id: "b",
        kind: :tool,
        preview: "bash: ls",
        jumpable?: false,
        head?: false,
        tip?: false,
        aborted?: false
      }
    ]

    st = %{
      model: "xai:g",
      profile: "base",
      tokens: %{cumulative: 0, window: 100},
      status: :idle,
      transcript: [],
      buffer: "",
      streaming: false,
      input: "",
      last_error: nil,
      tree: %{nodes: nodes, selected: 0, scroll: 0, window: 12}
    }

    frame = Arvo.TUI.Render.frame(st, width: 70, height: 16)
    assert frame =~ "Session Tree"
    assert frame =~ "hello tree"
    assert frame =~ "user" or frame =~ "assistant"
    assert frame =~ "HEAD"
    assert frame =~ "jump" or frame =~ "Esc close tree"
  end

  test "/tree opens picker; Esc closes without jump; Enter jumps" do
    tmp = Path.join(System.tmp_dir!(), "arvo-tree-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)

    on_exit(fn ->
      _ = Arvo.TUI.reset_idle()
      _ = Arvo.TUI.key(:esc)
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    _ = Arvo.TUI.reset_idle()
    {:ok, _path} = Arvo.Session.open_new(tmp)
    {:ok, _u1} = Arvo.Session.record_message(%{role: "user", content: "first"})
    {:ok, a1} = Arvo.Session.record_message(%{role: "assistant", content: "answer-one"})
    {:ok, _u2} = Arvo.Session.record_message(%{role: "user", content: "second-wrong"})
    {:ok, _a2} = Arvo.Session.record_message(%{role: "assistant", content: "answer-two"})

    assert {:ok, :tree, msg} = Arvo.TUI.slash("tree")
    assert msg =~ "Session Tree"
    st = Arvo.TUI.state()
    assert is_map(st.tree)
    assert length(st.tree.nodes) >= 4

    # Esc closes without head_move (status must be idle so Esc is not cancel)
    before_head = Arvo.Session.head_id()
    _ = Arvo.TUI.reset_idle()
    # re-open tree after reset_idle (reset does not clear tree — close then open)
    _ = Arvo.TUI.key(:esc)
    assert {:ok, :tree, _} = Arvo.TUI.slash("tree")
    assert :ok = Arvo.TUI.key(:esc)
    assert Arvo.TUI.state().tree == nil
    assert Arvo.Session.head_id() == before_head

    # Re-open and jump to first assistant
    assert {:ok, :tree, _} = Arvo.TUI.slash("tree")
    st = Arvo.TUI.state()
    # Select a1 by index
    idx = Enum.find_index(st.tree.nodes, &(&1.id == a1["id"]))
    assert is_integer(idx)

    # Move selection to a1
    for _ <- 1..idx, do: Arvo.TUI.key(:down)
    # Actually selected starts at HEAD (last); move up to a1
    # Reset: set selection by reopening is HEAD. Walk from HEAD up.
    assert {:ok, :tree, _} = Arvo.TUI.slash("tree")
    st = Arvo.TUI.state()
    head_sel = st.tree.selected
    a1_idx = Enum.find_index(st.tree.nodes, &(&1.id == a1["id"]))
    steps = head_sel - a1_idx

    if steps > 0 do
      for _ <- 1..steps, do: Arvo.TUI.key(:up)
    else
      for _ <- 1..abs(steps), do: Arvo.TUI.key(:down)
    end

    st = Arvo.TUI.state()
    assert Enum.at(st.tree.nodes, st.tree.selected).id == a1["id"]

    assert :ok = Arvo.TUI.key(:enter)
    st = Arvo.TUI.state()
    assert st.tree == nil
    assert Arvo.Session.head_id() == a1["id"]
    assert Enum.any?(st.transcript, &(&1.kind == :system && &1.text =~ "Navigated"))
    # Transcript rehydrated to HEAD chain only
    texts = Enum.map(st.transcript, fn e -> Map.get(e, :text) || Map.get(e, :summary) || "" end)
    assert Enum.any?(texts, &(&1 =~ "first"))
    assert Enum.any?(texts, &(&1 =~ "answer-one"))
    refute Enum.any?(texts, &(&1 =~ "second-wrong"))
  end

  test "tool node in tree is not jumpable" do
    tmp = Path.join(System.tmp_dir!(), "arvo-tree-tool-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)

    on_exit(fn ->
      _ = Arvo.TUI.key(:esc)
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    {:ok, _} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "run"})

    {:ok, _} =
      Arvo.Session.record_message(%{
        role: "assistant",
        content: "",
        tool_calls: [%{id: "t1", name: "bash", arguments: %{command: "echo x"}}]
      })

    {:ok, tool} =
      Arvo.Session.record_message(%{
        role: "tool",
        name: "bash",
        tool_call_id: "t1",
        content: "x"
      })

    assert {:ok, :tree, _} = Arvo.TUI.slash("tree")
    st = Arvo.TUI.state()
    tool_idx = Enum.find_index(st.tree.nodes, &(&1.id == tool["id"]))
    assert is_integer(tool_idx)
    refute Enum.at(st.tree.nodes, tool_idx).jumpable?

    # Select tool and Enter — no head change
    head_before = Arvo.Session.head_id()
    # Move selection from HEAD to tool
    sel = st.tree.selected
    steps = sel - tool_idx

    cond do
      steps > 0 ->
        for _ <- 1..steps, do: Arvo.TUI.key(:up)

      steps < 0 ->
        for _ <- 1..-steps, do: Arvo.TUI.key(:down)

      true ->
        :ok
    end

    assert :ok = Arvo.TUI.key(:enter)
    assert Arvo.Session.head_id() == head_before
    st = Arvo.TUI.state()
    # Tree stays open with error chrome (not buried under overlay)
    assert st.tree != nil
    assert is_binary(st.tree[:error]) and st.tree.error =~ "not a jump target"
    # Always leave tree closed for sibling tests sharing the TUI GenServer
    _ = Arvo.TUI.key(:esc)
  end

  describe "access chrome and enablement (U5)" do
    test "ambient enablement on without tools (AE10)" do
      :ok = Arvo.TUI.put_attention_mode("on")
      # cast — drain via sync state call
      st = Arvo.TUI.state()
      assert st.attention_mode == "on"

      frame = Arvo.TUI.Render.frame(st, width: 80, height: 12)
      plain = String.replace(frame, ~r/\e\[[0-9;]*m/, "")
      assert plain =~ "attn:on"
      refute plain =~ "attn:off"
    end

    test "attention-off: no access chrome; enablement off (AE4/R17)" do
      :ok = Arvo.TUI.put_attention_mode("off")
      st0 = Arvo.TUI.state()
      assert st0.attention_mode == "off"
      access_before = Enum.count(st0.transcript, &(&1.kind == :attention_access))

      :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})

      :ok =
        Arvo.TUI.handle_event_sync(
          {:tool_call_start, %{name: "bash", arguments: %{command: "echo off-mode"}}}
        )

      :ok =
        Arvo.TUI.handle_event_sync({
          :tool_call_end,
          %{
            name: "bash",
            is_error: false,
            text: "hello-off-mode",
            model_text: "hello-off-mode",
            attention_action: :full_hot
          }
        })

      st = Arvo.TUI.state()
      access_after = Enum.count(st.transcript, &(&1.kind == :attention_access))
      # No new access chrome under treatment off (R17)
      assert access_after == access_before

      act =
        st.transcript
        |> Enum.filter(&(&1.kind == :activity && &1.detail == "hello-off-mode"))
        |> List.last()

      assert act

      frame = Arvo.TUI.Render.frame(st, width: 80, height: 16)
      plain = String.replace(frame, ~r/\e\[[0-9;]*m/, "")
      assert plain =~ "attn:off"

      # Restore for sibling tests sharing the TUI GenServer
      :ok = Arvo.TUI.put_attention_mode("on")
      _ = Arvo.TUI.state()
    end

    test "denied expand chrome shows outcome reason_class cold id (AE3/R20)" do
      :ok = Arvo.TUI.put_attention_mode("on")
      _ = Arvo.TUI.state()

      :ok =
        Arvo.TUI.put_access_chrome(%{
          outcome: :denied,
          cold_id: "deadbeef",
          reason_class: "not_found",
          event_id: "evt-deny-1",
          actor: "user"
        })

      st = Arvo.TUI.state()

      access =
        Enum.find(
          st.transcript,
          &(&1.kind == :attention_access && &1.cold_id == "deadbeef" && &1.event_id == "evt-deny-1")
        )

      assert access
      assert access.outcome == :denied
      assert access.reason_class == "not_found"
      assert access.summary =~ "denied"
      assert access.detail =~ "not_found"
      assert access.detail =~ "cold:deadbeef"

      frame = Arvo.TUI.Render.frame(%{st | transcript: [access]}, width: 70, height: 12)
      plain = String.replace(frame, ~r/\e\[[0-9;]*m/, "")
      assert plain =~ "denied"
      assert plain =~ "cold:deadbeef" or plain =~ "not_found"
    end

    test "capped expand chrome is distinct from denied" do
      :ok =
        Arvo.TUI.put_access_chrome(%{
          outcome: :capped,
          cold_id: "big1",
          reason_class: "cap_exceeded",
          event_id: "evt-cap-1"
        })

      st = Arvo.TUI.state()
      access = Enum.find(st.transcript, &(&1.kind == :attention_access && &1.outcome == :capped))
      assert access
      assert access.reason_class == "cap_exceeded"
      assert access.summary =~ "capped"
    end

    test "projection filter strips access chrome from model-visible entries (R11/AE8)" do
      :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})

      :ok =
        Arvo.TUI.handle_event_sync({:tool_call_start, %{name: "read", arguments: %{path: "a"}}})

      :ok =
        Arvo.TUI.handle_event_sync({
          :tool_call_end,
          %{
            name: "read",
            text: "FULL BODY SECRET",
            model_text: "[cold:x tool=read bytes=12]",
            attention_action: :stub,
            cold_id: "x"
          }
        })

      st = Arvo.TUI.state()
      assert Enum.any?(st.transcript, &(&1.kind == :attention_access))

      model_entries = Arvo.TUI.model_projection_entries(st.transcript)
      refute Enum.any?(model_entries, &(&1.kind == :attention_access))

      # Chrome strings must not leak into model-filtered set as scripture
      chrome_blob =
        st.transcript
        |> Enum.filter(&(&1.kind == :attention_access))
        |> Enum.map_join(" ", &(&1.detail || ""))

      assert chrome_blob =~ "model saw" or chrome_blob =~ "[model:stub"

      model_blob =
        model_entries
        |> Enum.map_join(" ", fn e ->
          Map.get(e, :detail) || Map.get(e, :text) || Map.get(e, :summary) || ""
        end)

      refute model_blob =~ "dual-view"
      refute model_blob =~ "access ·"
    end

    test "one chrome item per projection with secondary store flag (R19)" do
      :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})
      before = Enum.count(Arvo.TUI.state().transcript, &(&1.kind == :attention_access))

      :ok =
        Arvo.TUI.handle_event_sync(
          {:tool_call_start, %{name: "bash", arguments: %{command: "x-r19"}}}
        )

      :ok =
        Arvo.TUI.handle_event_sync({
          :tool_call_end,
          %{
            name: "bash",
            text: "body-r19",
            model_text: "[cold:c1 tool=bash bytes=4]",
            attention_action: :stub,
            cold_id: "c1",
            event_id: "evt-agg-1",
            attention_secondary: [:store]
          }
        })

      st = Arvo.TUI.state()
      access_items = Enum.filter(st.transcript, &(&1.kind == :attention_access))
      # Exactly one new access chrome for this projection (R19 aggregation)
      assert length(access_items) == before + 1

      access = Enum.find(access_items, &(&1.event_id == "evt-agg-1"))
      assert access
      assert access.outcome == :stub
      assert :store in access.secondary
    end

    test "Session open_new casts ambient enablement" do
      tmp = Path.join(System.tmp_dir!(), "arvo-attn-en-#{System.unique_integer([:positive])}")
      File.mkdir_p!(tmp)
      old = System.get_env("HOME")
      System.put_env("HOME", tmp)
      Application.put_env(:arvo, :cwd, tmp)
      Application.put_env(:arvo, :progressive_attention, true)

      on_exit(fn ->
        if old, do: System.put_env("HOME", old)
        File.rm_rf!(tmp)
      end)

      {:ok, _path} = Arvo.Session.open_new(tmp)
      # cast drain
      Process.sleep(20)
      st = Arvo.TUI.state()
      assert st.attention_mode == "on"
      ghost = Arvo.TUI.Render.ghost_line(st, 100)
      plain = String.replace(ghost, ~r/\e\[[0-9;]*m/, "")
      assert plain =~ "attn:on"
    end

    test "Session recall denied casts access chrome with event_id" do
      tmp = Path.join(System.tmp_dir!(), "arvo-attn-deny-#{System.unique_integer([:positive])}")
      File.mkdir_p!(tmp)
      old = System.get_env("HOME")
      System.put_env("HOME", tmp)
      Application.put_env(:arvo, :cwd, tmp)

      on_exit(fn ->
        if old, do: System.put_env("HOME", old)
        File.rm_rf!(tmp)
      end)

      {:ok, path} = Arvo.Session.open_new(tmp)
      Process.sleep(10)
      _ = Arvo.TUI.reset_idle()

      assert {:error, :not_found} = Arvo.Session.recall("missing-id", actor: :user)
      Process.sleep(20)

      st = Arvo.TUI.state()

      access =
        Enum.find(
          st.transcript,
          &(&1.kind == :attention_access && &1.cold_id == "missing-id")
        )

      assert access
      assert access.outcome in [:denied, :capped]
      assert access.reason_class == "not_found"
      assert is_binary(access.event_id)

      # Join with durable trail
      events = Arvo.Session.Audit.list(path)
      deny = Enum.find(events, &(&1["type"] == "denied_expand" && &1["id"] == "missing-id"))
      assert deny
      assert deny["event_id"] == access.event_id
    end
  end

  describe "live pane chrome (R11b)" do
    setup do
      old = Application.get_env(:arvo, :herdr_adapter)
      {:ok, _} = Arvo.Herdr.Fake.start_link()
      Application.put_env(:arvo, :herdr_adapter, Arvo.Herdr.Fake)
      Arvo.Herdr.Fake.reset()
      _ = Arvo.Session.teardown_owned_panes(:tui_setup)

      on_exit(fn ->
        _ = Arvo.Session.teardown_owned_panes(:tui_cleanup)
        Arvo.Herdr.Fake.stop()

        if old do
          Application.put_env(:arvo, :herdr_adapter, old)
        else
          Application.delete_env(:arvo, :herdr_adapter)
        end
      end)

      :ok
    end

    test "after long_lived return (idle), ghost shows pane command" do
      {:ok, id} = Arvo.Herdr.split([])

      assert :ok =
               Arvo.Session.register_pane(%{
                 pane_id: id,
                 mode: :long_lived,
                 command: "mix phx.server",
                 start_reaper: false
               })

      :ok = Arvo.TUI.handle_event_sync({:agent_start, %{}})
      :ok = Arvo.TUI.handle_event_sync({:agent_end, %{}})
      st = Arvo.TUI.state()
      assert st.status == :idle
      assert length(st.live_panes) == 1

      ghost = Arvo.TUI.Render.ghost_line(st, 120)
      # ANSI-stripped check
      plain = String.replace(ghost, ~r/\e\[[0-9;]*m/, "")
      assert plain =~ "pane"
      assert plain =~ "mix phx.server" or plain =~ "running"

      assert {:ok, _} = Arvo.Session.teardown_owned_panes(:cancel)
      panes = Arvo.TUI.refresh_live_panes()
      assert panes == []
      st = Arvo.TUI.state()
      ghost2 = Arvo.TUI.Render.ghost_line(st, 120)
      plain2 = String.replace(ghost2, ~r/\e\[[0-9;]*m/, "")
      refute plain2 =~ "mix phx.server"
    end
  end
end
