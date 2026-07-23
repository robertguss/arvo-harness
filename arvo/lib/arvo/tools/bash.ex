defmodule Arvo.Tools.Bash do
  @moduledoc "Run a shell command with merged stdout/stderr and tail truncation (SPEC §3)."


  use Jido.Action,
    name: "bash",
    description:
      "Run a shell command. stdout and stderr are merged. Default timeout 120s. Truncated output keeps the tail and spills the full log to a temp file.",
    category: "tools",
    tags: ["shell", "bash"],
    vsn: "0.1.0",
    schema: [
      command: [type: :string, required: true, doc: "Shell command to run"],
      timeout: [
        type: :pos_integer,
        required: false,
        doc: "Timeout in seconds (default 120)"
      ]
    ]

  # ~100 KB of text in the result; rest spills to file
  @max_output_bytes 100_000

  @doc false
  def spec, do: Arvo.Tool.spec_from_jido(__MODULE__)

  @impl Jido.Action
  def run(params, ctx) do
    command = params[:command] || params["command"]
    timeout_s = params[:timeout] || params["timeout"] || 120
    timeout_ms = timeout_s * 1000
    cwd = Map.get(ctx || %{}, :cwd) || Map.get(ctx || %{}, "cwd") || File.cwd!()

    case run_command(command, cwd, timeout_ms) do
      {:ok, {output, exit_code}} ->
        {:ok, format_output(output, exit_code)}

      {:error, :timeout} ->
        {:error, "Command timed out after #{timeout_s}s: #{command}"}

      {:error, reason} ->
        {:error, "Failed to run command: #{inspect(reason)}"}
    end
  end

  @doc false
  def run_command(command, cwd, timeout_ms) do
    task =
      Task.async(fn ->
        System.cmd("bash", ["-c", command], cd: cwd, stderr_to_stdout: true)
      end)

    case Task.yield(task, timeout_ms) || Task.shutdown(task, :brutal_kill) do
      {:ok, {output, code}} when is_binary(output) and is_integer(code) ->
        {:ok, {output, code}}

      nil ->
        {:error, :timeout}

      {:exit, reason} ->
        {:error, reason}

      other ->
        {:error, other}
    end
  end

  defp format_output(output, exit_code) do
    {body, note} =
      if byte_size(output) > @max_output_bytes do
        spill = spill_path()
        File.write!(spill, output)
        tail = binary_slice_tail(output, @max_output_bytes)

        {tail, "\n[Output truncated to last #{@max_output_bytes} bytes; full output: #{spill}]"}
      else
        {output, ""}
      end

    status =
      if exit_code == 0 do
        ""
      else
        "\n[exit code #{exit_code}]"
      end

    body <> note <> status
  end

  defp spill_path do
    Path.join(System.tmp_dir!(), "arvo-bash-#{System.unique_integer([:positive])}.log")
  end

  defp binary_slice_tail(bin, max) when byte_size(bin) > max do
    binary_part(bin, byte_size(bin) - max, max)
  end

  defp binary_slice_tail(bin, _), do: bin
end
