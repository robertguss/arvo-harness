defmodule Arvo.Isolation do
  @moduledoc """
  Env and disk latches for agent-facing tool children.

  `cmd_env/0` is a `System.cmd/3` `:env` overlay that unsets named secrets.
  Other keys still inherit. `resolve_tool_path/2` expands, then refuses
  `$HOME/.arvo`.
  """

  @secret_env_names ~w(XAI_API_KEY RELEASE_COOKIE ARVO_AUTH_FILE)
  @api_key_suffix "_API_KEY"

  @doc """
  `{key, nil}` tuples for `System.cmd/3`'s `:env` option.

  Listed names are always cleared. Any currently set key ending in `_API_KEY`
  is cleared too. PATH, HOME, GIT_DIR, and SSH_AUTH_SOCK still inherit.
  """
  def cmd_env do
    live_api_keys =
      for {name, _value} <- System.get_env(),
          String.ends_with?(name, @api_key_suffix),
          do: name

    @secret_env_names
    |> Enum.concat(live_api_keys)
    |> Enum.uniq()
    |> Enum.map(&{&1, nil})
  end

  @doc """
  Expand `path`, then refuse `$HOME/.arvo` and its descendants.

  Absolute paths go through `Path.expand/1` so `..` collapses. Relative
  paths expand against `ctx.cwd`, `ctx["cwd"]`, or `File.cwd!/0`. A
  `<cwd>/.arvo` tree is allowed unless that expanded path is under
  `$HOME/.arvo`. The error string does not include file contents.
  """
  def resolve_tool_path(path, ctx) when is_binary(path) do
    abs =
      case Path.type(path) do
        :absolute -> Path.expand(path)
        _ -> Path.expand(path, cwd(ctx))
      end

    root = Path.expand(Path.join(System.get_env("HOME") || System.user_home!(), ".arvo"))

    if abs == root or String.starts_with?(abs, root <> "/") do
      {:error, "Refused: path is under the Arvo home store"}
    else
      {:ok, abs}
    end
  end

  defp cwd(ctx) do
    Map.get(ctx || %{}, :cwd) || Map.get(ctx || %{}, "cwd") || File.cwd!()
  end
end
