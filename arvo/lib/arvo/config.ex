defmodule Arvo.Config do
  @moduledoc """
  TOML config loader for `~/.arvo/config.toml` and `<cwd>/.arvo/config.toml`.

  Unknown keys warn and are ignored (SPEC §11). Project config accepts `profile` only in v0.1.
  """

  require Logger

  @global_known_keys MapSet.new(["default_model", "providers"])
  @project_known_keys MapSet.new(["profile"])

  @type t :: %{
          default_model: String.t() | nil,
          providers: map(),
          profile: String.t() | nil,
          cwd: String.t()
        }

  @doc "Load global then project config. Project values overlay where defined."
  def load(cwd) when is_binary(cwd) do
    home = System.get_env("HOME") || System.user_home!()
    global_path = Path.join([home, ".arvo", "config.toml"])
    project_path = Path.join([cwd, ".arvo", "config.toml"])

    global = parse_file(global_path, :global)
    project = parse_file(project_path, :project)

    %{
      default_model: Map.get(global, "default_model") || "xai:grok-4.5",
      providers: Map.get(global, "providers") || %{},
      profile: Map.get(project, "profile"),
      cwd: cwd
    }
  end

  @doc "Parse a TOML config file. Missing file → empty map. Unknown keys → warn + drop."
  def parse_file(path, scope) when scope in [:global, :project] do
    case File.read(path) do
      {:ok, contents} ->
        case Toml.decode(contents) do
          {:ok, map} when is_map(map) ->
            filter_known(map, scope, path)

          {:error, reason} ->
            Logger.warning("Arvo config: failed to parse #{path}: #{inspect(reason)}")
            %{}
        end

      {:error, :enoent} ->
        %{}

      {:error, reason} ->
        Logger.warning("Arvo config: cannot read #{path}: #{inspect(reason)}")
        %{}
    end
  end

  @doc false
  def filter_known(map, scope, path \\ "<inline>") when is_map(map) do
    known =
      case scope do
        :global -> @global_known_keys
        :project -> @project_known_keys
      end

    Enum.reduce(map, %{}, fn {key, value}, acc ->
      key_str = to_string(key)

      if MapSet.member?(known, key_str) do
        Map.put(acc, key_str, value)
      else
        Logger.warning(
          "Arvo config: unknown key #{inspect(key_str)} in #{path} (#{scope}); ignoring"
        )

        acc
      end
    end)
  end
end
