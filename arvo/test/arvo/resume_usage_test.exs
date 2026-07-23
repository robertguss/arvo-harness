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
  end

  test "usage line shows turn and cumulative/window" do
    :ok = Arvo.TUI.put_tokens(12, 340, 500_000)
    line = Arvo.TUI.usage_line()
    assert line =~ "12"
    assert line =~ "340"
    assert line =~ "500000" or line =~ "500_000" or line =~ "/500"
  end
end
