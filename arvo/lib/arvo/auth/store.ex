defmodule Arvo.Auth.Store do
  @moduledoc """
  Persist credentials in `~/.arvo/auth.json` (mode 0600), keyed by provider name.
  """

  @filename "auth.json"

  def path do
    home = System.get_env("HOME") || System.user_home!()
    Path.join([home, ".arvo", @filename])
  end

  @doc "Load all provider credentials. Missing file → `%{}`."
  def load do
    case File.read(path()) do
      {:ok, body} ->
        case Jason.decode(body) do
          {:ok, map} when is_map(map) -> map
          _ -> %{}
        end

      {:error, :enoent} ->
        %{}

      {:error, _} ->
        %{}
    end
  end

  @doc "Read one provider entry."
  def get(provider) when is_binary(provider) do
    Map.get(load(), provider)
  end

  @doc "Write/merge one provider entry; file mode 0600."
  def put(provider, creds) when is_binary(provider) and is_map(creds) do
    dir = Path.dirname(path())
    File.mkdir_p!(dir)
    data = load() |> Map.put(provider, creds)
    body = Jason.encode!(data, pretty: true)
    File.write!(path(), body)
    File.chmod!(path(), 0o600)
    :ok
  end

  @doc "Delete a provider entry."
  def delete(provider) when is_binary(provider) do
    data = load() |> Map.delete(provider)
    dir = Path.dirname(path())
    File.mkdir_p!(dir)
    File.write!(path(), Jason.encode!(data, pretty: true))
    File.chmod!(path(), 0o600)
    :ok
  end
end
