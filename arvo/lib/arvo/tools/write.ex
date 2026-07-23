defmodule Arvo.Tools.Write do
  @moduledoc "Write a file, creating parent directories (SPEC §3)."


  use Jido.Action,
    name: "write",
    description: "Write content to a file. Creates parent directories if needed.",
    category: "tools",
    tags: ["filesystem", "write"],
    vsn: "0.1.0",
    schema: [
      path: [type: :string, required: true, doc: "Path to write"],
      content: [type: :string, required: true, doc: "File contents"]
    ]

  @doc false
  def spec, do: Arvo.Tool.spec_from_jido(__MODULE__)

  @impl Jido.Action
  def run(params, ctx) do
    path = resolve_path(params[:path] || params["path"], ctx)
    content = params[:content] || params["content"] || ""

    parent = Path.dirname(path)

    with :ok <- File.mkdir_p(parent),
         :ok <- File.write(path, content) do
      {:ok, "Wrote #{byte_size(content)} bytes to #{path}"}
    else
      {:error, reason} ->
        {:error, "Failed to write #{path}: #{inspect(reason)}"}
    end
  end

  defp resolve_path(path, ctx) when is_binary(path) do
    if Path.type(path) == :absolute do
      path
    else
      cwd = Map.get(ctx || %{}, :cwd) || Map.get(ctx || %{}, "cwd") || File.cwd!()
      Path.expand(path, cwd)
    end
  end
end
