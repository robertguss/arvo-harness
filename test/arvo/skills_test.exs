defmodule Arvo.SkillsTest do
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-skills-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      File.rm_rf!(tmp)
    end)

    user = Path.join([tmp, ".arvo", "skills", "hello"])
    File.mkdir_p!(user)
    File.write!(Path.join(user, "SKILL.md"), """
    ---
    name: hello-skill
    description: Greets the user warmly
    ---
    # Hello
    Say hello.
    """)

    plugin = Path.join(tmp, "plug")
    pskill = Path.join([plugin, "priv", "skills", "search"])
    File.mkdir_p!(pskill)
    File.write!(Path.join(pskill, "SKILL.md"), """
    # Search skill
    How to search the codebase.
    """)

    %{tmp: tmp, plugin: plugin}
  end

  test "discovers user and plugin skills", %{plugin: plugin} do
    skills = Arvo.Skills.discover(plugin_dirs: [plugin])
    names = Enum.map(skills, & &1.name)
    assert "hello-skill" in names
    assert Enum.any?(skills, &(&1.description =~ "Greets" or &1.name =~ "search" or &1.description =~ "search"))
  end

  test "prompt includes available_skills block", %{plugin: plugin} do
    skills = Arvo.Skills.discover(plugin_dirs: [plugin])
    prompt = Arvo.Prompt.assemble(cwd: plugin, tools: [], skills: skills)
    assert prompt =~ "available_skills"
    assert prompt =~ "hello-skill"
  end
end
