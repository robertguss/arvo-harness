defmodule Arvo.Tools.RecallEvidence do
  @moduledoc """
  Model-callable bounded recovery of cold evidence (KTD-R1).

  Thin wrapper over `Session.recall` / `Attention.expand` with `actor: :model`.
  Same expand caps as human `/recall`. Result is a normal tool string, not chrome.
  """

  use Jido.Action,
    name: "RecallEvidence",
    description:
      "Expand a cold evidence body into a bounded hot slice under size caps. Use when a tool result is a cold stub like [cold:<id> …] and you need the full body (or a larger prefix) to continue. Prefer the cold_id from the stub. Over-cap or missing ids return an error; re-try with a smaller max_bytes if denied for cap.",
    category: "tools",
    tags: ["attention", "cold", "recovery"],
    vsn: "0.1.0",
    schema: [
      cold_id: [
        type: :string,
        required: true,
        doc: "Cold evidence id from a [cold:<id> …] stub"
      ],
      max_bytes: [
        type: :pos_integer,
        required: false,
        doc: "Max bytes to expand (default: policy expand cap)"
      ]
    ]

  @doc false
  def spec, do: Arvo.Tool.spec_from_jido(__MODULE__)

  @impl Jido.Action
  def run(params, ctx) do
    cold_id = params[:cold_id] || params["cold_id"]
    max_bytes = params[:max_bytes] || params["max_bytes"]
    tool_call_id = Map.get(ctx || %{}, :tool_call_id) || Map.get(ctx || %{}, "tool_call_id")

    if not is_binary(cold_id) or cold_id == "" do
      {:error, "cold_id is required"}
    else
      opts = [actor: :model]
      opts = if is_binary(tool_call_id), do: Keyword.put(opts, :tool_call_id, tool_call_id), else: opts

      # max_bytes is the requested slice only; policy expand cap stays default
      # (same as human /recall) so models cannot raise the cap.
      opts =
        if is_integer(max_bytes) and max_bytes > 0 do
          Keyword.put(opts, :max_bytes, max_bytes)
        else
          opts
        end

      do_recall(cold_id, opts)
    end
  end

  defp do_recall(cold_id, opts) do
    try do
      case Arvo.Session.recall(cold_id, opts) do
        {:ok, text} when is_binary(text) ->
          {:ok, text}

        {:error, :not_found} ->
          {:error, "Cold evidence not found: #{cold_id}"}

        {:error, :over_cap} ->
          {:error,
           "Expand denied: requested slice exceeds expand cap for cold:#{cold_id}. Retry with smaller max_bytes."}

        {:error, :no_session} ->
          {:error, "No open session; cannot recall cold evidence"}

        {:error, reason} ->
          {:error, "Recall failed for cold:#{cold_id}: #{format_reason(reason)}"}
      end
    catch
      :exit, _ ->
        {:error, "No open session; cannot recall cold evidence"}
    end
  end

  defp format_reason(reason) when is_atom(reason), do: Atom.to_string(reason)
  defp format_reason(reason) when is_binary(reason), do: reason
  defp format_reason(reason), do: inspect(reason)
end
