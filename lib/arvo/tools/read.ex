defmodule Arvo.Tools.Read do
  @moduledoc "Read a text file with 1-indexed offset/limit and size caps (SPEC §3)."

  use Jido.Action,
    name: "read",
    description:
      "Read a text file. offset is 1-indexed. Binary/image files are rejected. Output is capped by max lines and max KB.",
    category: "tools",
    tags: ["filesystem", "read"],
    vsn: "0.1.0",
    schema: [
      path: [type: :string, required: true, doc: "Path to read (absolute or relative to cwd)"],
      offset: [type: :pos_integer, required: false, doc: "1-indexed start line (default 1)"],
      limit: [type: :pos_integer, required: false, doc: "Max lines to return from offset"]
    ]

  @max_lines 2000
  @max_bytes 50_000

  @doc false
  def spec, do: Arvo.Tool.spec_from_jido(__MODULE__)

  @impl Jido.Action
  def run(params, ctx) do
    offset = params[:offset] || params["offset"] || 1
    limit = params[:limit] || params["limit"]

    with {:ok, path} <- Arvo.Isolation.resolve_tool_path(params[:path] || params["path"], ctx),
         :ok <- ensure_exists(path),
         :ok <- reject_binary(path),
         {:ok, content} <- File.read(path) do
      lines = String.split(content, ~r/\r\n|\n|\r/, trim: false)
      total = length(lines)
      start_idx = max(offset - 1, 0)

      if start_idx >= total and total > 0 do
        {:error,
         "offset #{offset} is past end of file (#{total} lines). Re-read with a smaller offset."}
      else
        slice = Enum.drop(lines, start_idx)
        slice = if limit, do: Enum.take(slice, limit), else: slice

        {body_lines, _truncated_by_lines, _truncated_by_bytes, end_line} =
          take_with_caps(slice, start_idx, @max_lines, @max_bytes)

        body = Enum.join(body_lines, "\n")
        shown_start = start_idx + 1
        shown_end = end_line

        result =
          if shown_end < total do
            next = shown_end + 1

            body <>
              "\n[Showing lines #{shown_start}–#{shown_end} of #{total}. Use offset=#{next} to continue.]"
          else
            body
          end

        {:ok, result}
      end
    end
  end

  defp ensure_exists(path) do
    if File.exists?(path) do
      :ok
    else
      {:error, "File not found: #{path}"}
    end
  end

  defp reject_binary(path) do
    case File.open(path, [:read, :binary], fn io -> IO.binread(io, 8192) end) do
      {:ok, :eof} ->
        :ok

      {:ok, chunk} when is_binary(chunk) ->
        if String.valid?(chunk) and not String.contains?(chunk, <<0>>) do
          :ok
        else
          {:error,
           "Cannot read binary or image file: #{path}. Only text files are supported by the read tool."}
        end

      {:error, reason} ->
        {:error, "Cannot open file #{path}: #{inspect(reason)}"}
    end
  end

  defp take_with_caps(lines, start_idx, max_lines, max_bytes) do
    Enum.reduce_while(lines, {[], 0, 0, false, false, start_idx}, fn line,
                                                                     {acc, count, bytes, t_lines,
                                                                      t_bytes, last} ->
      line_bytes = byte_size(line) + if(acc == [], do: 0, else: 1)

      cond do
        count >= max_lines ->
          {:halt, {acc, count, bytes, true, t_bytes, last}}

        bytes + line_bytes > max_bytes and acc != [] ->
          {:halt, {acc, count, bytes, t_lines, true, last}}

        true ->
          {:cont, {[line | acc], count + 1, bytes + line_bytes, t_lines, t_bytes, last + 1}}
      end
    end)
    |> then(fn {acc, _c, _b, t_lines, t_bytes, end_line} ->
      {Enum.reverse(acc), t_lines, t_bytes, end_line}
    end)
  end
end
