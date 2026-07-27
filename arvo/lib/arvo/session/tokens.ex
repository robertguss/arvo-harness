defmodule Arvo.Session.Tokens do
  @moduledoc "Per-turn + cumulative context token accounting from usage maps."

  defstruct turn_input: 0,
            turn_output: 0,
            cumulative_input: 0,
            cumulative_output: 0,
            cumulative_total: 0

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}

  @doc """
  Normalize a provider/session usage map to `%{input_tokens, output_tokens}`.

  Accepts `input_tokens`/`output_tokens` or `prompt_tokens`/`completion_tokens`
  (atom or string keys).
  """
  def input_output(usage) when is_map(usage) do
    %{
      input_tokens:
        usage[:input_tokens] || usage["input_tokens"] || usage[:prompt_tokens] ||
          usage["prompt_tokens"] || 0,
      output_tokens:
        usage[:output_tokens] || usage["output_tokens"] || usage[:completion_tokens] ||
          usage["completion_tokens"] || 0
    }
  end

  @doc "Add a usage map (`input_tokens`/`output_tokens` or `prompt_tokens`/`completion_tokens`)."
  def add(%__MODULE__{} = acc, usage) when is_map(usage) do
    %{input_tokens: input, output_tokens: output} = input_output(usage)

    %__MODULE__{
      turn_input: input,
      turn_output: output,
      cumulative_input: acc.cumulative_input + input,
      cumulative_output: acc.cumulative_output + output,
      cumulative_total: acc.cumulative_total + input + output
    }
  end
end
