defmodule Fff.SearchTool do
  @moduledoc "Search tool for the fff plugin — Rustler NIF (`Fff.Native.search/2`)."

  use Jido.Action,
    name: "fff_search",
    description: "Search the project for a pattern (fff flagship plugin / Rustler NIF).",
    schema: [
      pattern: [type: :string, required: true, doc: "Search pattern (substring)"],
      path: [type: :string, required: false, doc: "Directory to search (default cwd)"]
    ]

  def spec, do: Arvo.Tool.spec_from_jido(__MODULE__)

  @impl Jido.Action
  def run(params, ctx) do
    pattern = params[:pattern] || params["pattern"]
    path = params[:path] || params["path"] || Map.get(ctx || %{}, :cwd) || File.cwd!()

    case Fff.Native.search(pattern, path) do
      {:ok, out} when is_binary(out) -> {:ok, out}
      {:error, reason} when is_binary(reason) -> {:error, reason}
      {:error, reason} -> {:error, inspect(reason)}
      other -> {:error, "unexpected NIF result: #{inspect(other)}"}
    end
  end
end
