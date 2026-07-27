defmodule Arvo.ResumeUsageTest do
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-resume-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    %{tmp: tmp}
  end

  test "/resume lists and resumes session", %{tmp: tmp} do
    {:ok, path} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "resume-me"})

    assert {:ok, :handled, list} = Arvo.TUI.slash("resume")
    assert list =~ Path.basename(path)

    assert {:ok, :handled, msg} = Arvo.TUI.slash("resume", "1")
    assert msg =~ "resumed"
    assert msg =~ Path.basename(path)
  end

  test "/resume 1 skips empty boot sessions and picks last chat", %{tmp: tmp} do
    # Simulated "real" prior chat
    {:ok, chat_path} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "remember PURPLE-LLAMA-42"})
    {:ok, _} = Arvo.Session.record_message(%{role: "assistant", content: "remembered."})

    # Newer empty shell (what boot open_new used to create) — sorts first by name
    {:ok, empty_path} = Arvo.Session.open_new(tmp)
    assert File.exists?(empty_path)
    # empty has only session_meta

    all = Arvo.Session.Store.list_for_cwd(tmp)
    resumable = Arvo.Session.Store.list_resumable_for_cwd(tmp)

    assert empty_path in all
    refute empty_path in resumable
    assert List.first(resumable) == chat_path

    assert {:ok, :handled, list} = Arvo.TUI.slash("resume")
    assert list =~ Path.basename(chat_path)
    refute list =~ Path.basename(empty_path)

    assert {:ok, :handled, msg} = Arvo.TUI.slash("resume", "1")
    assert msg =~ Path.basename(chat_path)
    assert msg =~ "2 messages" or msg =~ "messages"
  end

  test "Repl boot does not open_new (lazy session on first chat)" do
    src = File.read!(Path.expand("../../lib/arvo/repl.ex", __DIR__))
    # Isolate run/1 body only (ends at next top-level def)
    [_, run_body | _] = Regex.run(~r/def run\(device.*?do\n(.*?\n)  end\n/s, src)
    refute run_body =~ "ensure_session"
    assert src =~ "ensure_session(Application.get_env"
  end

  test "usage line shows turn and cumulative/window" do
    :ok = Arvo.TUI.put_tokens(12, 340, 500_000)
    line = Arvo.TUI.usage_line()
    assert line =~ "12"
    assert line =~ "340"
    assert line =~ "500000" or line =~ "500_000" or line =~ "/500"
  end

  test "record_usage durable; resume rehydrates non-zero cumulative tokens (AE2)", %{tmp: tmp} do
    {:ok, path} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "hi"})
    {:ok, tokens} = Arvo.Session.record_usage(%{input_tokens: 100, output_tokens: 40})
    assert tokens.cumulative_total == 140

    # Kill simulation: re-resume from path only
    assert {:ok, resumed} = Arvo.Session.resume(path)
    assert resumed.tokens.cumulative_total == 140
    assert Arvo.Session.tokens().cumulative_total == 140
  end

  test "model and profile name round-trip on resume", %{tmp: tmp} do
    {:ok, path} = Arvo.Session.open_new(tmp, model: "xai:custom-model", profile: "search")
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "x"})
    assert {:ok, resumed} = Arvo.Session.resume(path)
    assert resumed.model == "xai:custom-model"
    assert resumed.profile == "search"
  end

  test "auto-resume same cwd skips empty shells", %{tmp: tmp} do
    {:ok, chat} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "keep"})
    {:ok, empty} = Arvo.Session.open_new(tmp)

    Application.put_env(:arvo, :auto_resume, true)
    Application.put_env(:arvo, :cwd, tmp)

    on_exit(fn -> Application.put_env(:arvo, :auto_resume, false) end)

    assert {:ok, %{path: path}} = Arvo.Application.maybe_auto_resume(tmp)
    assert path == chat
    refute path == empty
  end

  test "auto-resume after rewind uses HEAD messages not abandoned tip", %{tmp: tmp} do
    {:ok, path} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "u1"})
    {:ok, a1} = Arvo.Session.record_message(%{role: "assistant", content: "a1"})
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "u2-abandoned"})
    {:ok, _} = Arvo.Session.rewind(1)
    assert Arvo.Session.head_id() == a1["id"]

    assert {:ok, resumed} = Arvo.Session.resume(path)
    contents = Enum.map(resumed.messages, & &1.content)
    assert "u1" in contents
    assert "a1" in contents
    refute "u2-abandoned" in contents
  end
end

