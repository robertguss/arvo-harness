defmodule Arvo.Skills do
  @moduledoc """
  SKILL.md discovery from plugin priv/skills/ and ~/.arvo/skills/ (SPEC §5/§8).
  """

  @doc """
  Discover skills. Options:
  - `:plugin_dirs` — list of plugin roots
  - `:user_dir` — override `~/.arvo/skills`
  """
  def discover(opts \\ []) do
    user_dir =
      Keyword.get(opts, :user_dir) ||
        Path.join([System.get_env("HOME") || System.user_home!(), ".arvo", "skills"])

    plugin_dirs = Keyword.get(opts, :plugin_dirs) || []

    (Enum.flat_map(plugin_dirs, &skills_in_dir(Path.join(&1, "priv/skills"))) ++
       skills_in_dir(user_dir))
    |> Enum.uniq_by(& &1.name)
  end

  def skills_in_dir(dir) do
    if File.dir?(dir) do
      dir
      |> File.ls!()
      |> Enum.flat_map(fn name ->
        skill_md = Path.join([dir, name, "SKILL.md"])

        if File.exists?(skill_md) do
          {title, desc} = parse_skill_md(skill_md)
          [%{name: title || name, description: desc, path: skill_md}]
        else
          []
        end
      end)
    else
      []
    end
  end

  def parse_skill_md(path) do
    body = File.read!(path)
    # Optional YAML front matter
    {meta, rest} =
      case Regex.run(~r/\A---\n(.*?)\n---\n(.*)\z/s, body) do
        [_, yaml, content] -> {parse_simple_yaml(yaml), content}
        _ -> {%{}, body}
      end

    name = meta["name"] || first_heading(rest) || Path.basename(Path.dirname(path))
    desc = meta["description"] || first_paragraph(rest) || ""
    {name, String.trim(desc)}
  end

  defp parse_simple_yaml(yaml) do
    yaml
    |> String.split("\n")
    |> Enum.reduce(%{}, fn line, acc ->
      case String.split(line, ":", parts: 2) do
        [k, v] -> Map.put(acc, String.trim(k), String.trim(v) |> String.trim("\"'"))
        _ -> acc
      end
    end)
  end

  defp first_heading(body) do
    case Regex.run(~r/^#\s+(.+)$/m, body) do
      [_, h] -> String.trim(h)
      _ -> nil
    end
  end

  defp first_paragraph(body) do
    body
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == "" or String.starts_with?(&1, "#")))
    |> List.first()
  end
end
