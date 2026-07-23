defmodule Arvo.PromptTest do
  use ExUnit.Case, async: true

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-prompt-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    on_exit(fn -> File.rm_rf!(tmp) end)
    %{tmp: tmp}
  end

  test "assemble includes core + environment + tool schemas", %{tmp: tmp} do
    prompt = Arvo.Prompt.assemble(cwd: tmp, tools: [Arvo.Tools.Read], date: "2026-07-23")
    assert prompt =~ "Arvo"
    assert prompt =~ tmp
    assert prompt =~ "2026-07-23"
    assert prompt =~ "read" or prompt =~ "Tools"
  end

  test "missing AGENTS.md omits project block", %{tmp: tmp} do
    prompt = Arvo.Prompt.assemble(cwd: tmp, tools: [])
    refute prompt =~ "Project instructions"
  end

  test "AGENTS.md included verbatim when present", %{tmp: tmp} do
    File.write!(Path.join(tmp, "AGENTS.md"), "ALWAYS use tabs")
    prompt = Arvo.Prompt.assemble(cwd: tmp, tools: [])
    assert prompt =~ "ALWAYS use tabs"
    assert prompt =~ "Project instructions"
  end
end
