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
end
