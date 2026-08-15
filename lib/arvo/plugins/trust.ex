defmodule Arvo.Plugins.Trust do
  @moduledoc "Once-per-project trust gate recorded in `~/.arvo/trust.json`."

  def path do
    home = System.get_env("HOME") || System.user_home!()
    Path.join([home, ".arvo", "trust.json"])
  end

  def load do
    case File.read(path()) do
      {:ok, body} ->
        case Jason.decode(body) do
          {:ok, %{"trusted" => list}} when is_list(list) -> MapSet.new(list)
          {:ok, list} when is_list(list) -> MapSet.new(list)
          _ -> MapSet.new()
        end

      _ ->
        MapSet.new()
    end
  end

  def trusted?(project_path) when is_binary(project_path) do
    MapSet.member?(load(), Path.expand(project_path))
  end

  def trust!(project_path) when is_binary(project_path) do
    abs = Path.expand(project_path)
    set = load() |> MapSet.put(abs)
    write!(set)
    :ok
  end

  def untrust!(project_path) when is_binary(project_path) do
    abs = Path.expand(project_path)
    set = load() |> MapSet.delete(abs)
    write!(set)
    :ok
  end

  @doc """
  Ensure project is trusted. If `prompt_fun` returns true, record trust.
  `prompt_fun` defaults to auto-deny in non-interactive (tests should pass explicit fun).
  """
  def ensure_trusted(project_path, prompt_fun \\ &default_prompt/1) do
    abs = Path.expand(project_path)

    if trusted?(abs) do
      :ok
    else
      if prompt_fun.(abs) do
        trust!(abs)
        :ok
      else
        {:error, :untrusted}
      end
    end
  end

  defp write!(set) do
    dir = Path.dirname(path())
    File.mkdir_p!(dir)
    body = Jason.encode!(%{"trusted" => MapSet.to_list(set)}, pretty: true)
    File.write!(path(), body)
    File.chmod!(path(), 0o600)
    :ok
  end

  defp default_prompt(_path), do: false
end
