defmodule Arvo.Prompt do
  @moduledoc """
  System prompt assembly (SPEC §8): core template + environment + AGENTS.md + skills + tool schemas.
  """

  @doc """
  Build the full system prompt string.

  Options:
  - `:cwd` — project directory (ARVO_CWD)
  - `:tools` — list of tool modules implementing `spec/0`
  - `:skills` — optional list of `%{name, description, path}`
  - `:date` — optional Date or string
  """
  def assemble(opts \\ []) do
    cwd = Keyword.get(opts, :cwd) || Arvo.cwd()
    tools = Keyword.get(opts, :tools) || Arvo.Tool.core_tools()
    skills = Keyword.get(opts, :skills) || []
    date = Keyword.get(opts, :date) || Date.utc_today() |> to_string()

    [
      core_prompt(),
      environment_block(cwd, date),
      agents_md_block(cwd),
      skills_block(skills),
      tool_schemas_block(tools)
    ]
    |> Enum.reject(&(&1 == "" or is_nil(&1)))
    |> Enum.join("\n\n")
  end

  def core_prompt do
    path = Path.join(:code.priv_dir(:arvo), "prompts/system.md.eex")

    if File.exists?(path) do
      EEx.eval_file(path, [])
    else
      "You are Arvo, a coding agent."
    end
  end

  def environment_block(cwd, date) do
    os = :os.type() |> Tuple.to_list() |> Enum.map_join(" ", &to_string/1)
    git = git_oneline(cwd)

    """
    ## Environment
    - cwd: #{cwd}
    - os: #{os}
    - date: #{date}
    #{if git, do: "- git: #{git}", else: ""}
    """
    |> String.trim()
  end

  def agents_md_block(cwd) do
    path = Path.join(cwd, "AGENTS.md")

    case File.read(path) do
      {:ok, contents} ->
        "## Project instructions (AGENTS.md)\n\n" <> contents

      {:error, _} ->
        ""
    end
  end

  def skills_block([]), do: ""

  def skills_block(skills) when is_list(skills) do
    rows =
      Enum.map_join(skills, "\n", fn s ->
        name = Map.get(s, :name) || Map.get(s, "name")
        desc = Map.get(s, :description) || Map.get(s, "description")
        path = Map.get(s, :path) || Map.get(s, "path")
        "- #{name}: #{desc} (#{path})"
      end)

    "<available_skills>\n#{rows}\n</available_skills>"
  end

  def tool_schemas_block(tools) do
    schemas =
      Enum.map(tools, fn mod ->
        spec = mod.spec()
        Jason.encode!(%{name: spec.name, description: spec.description, parameters: spec.parameters})
      end)

    "## Tools\n\n" <> Enum.join(schemas, "\n")
  end

  defp git_oneline(cwd) do
    case System.cmd("git", ["status", "-sb"], cd: cwd, stderr_to_stdout: true) do
      {out, 0} -> String.trim(out) |> String.split("\n") |> List.first()
      _ -> nil
    end
  rescue
    _ -> nil
  end
end
