defmodule Arvo.Tool do
  @moduledoc """
  Tool behaviour wrapping jido_action for validation + JSON Schema export (SPEC §3).

  Result shape for the model: text + is_error (encoded as `{:ok, text}` / `{:error, text}`).
  """

  @type ctx :: %{
          optional(:cwd) => String.t(),
          optional(:session_id) => String.t() | nil,
          optional(:config) => map()
        }

  @callback spec() :: %{
              name: String.t(),
              description: String.t(),
              parameters: map()
            }

  @callback run(args :: map(), ctx :: ctx()) :: {:ok, String.t()} | {:error, String.t()}

  @doc "Core v0.1 tool modules."
  def core_tools do
    [Arvo.Tools.Read, Arvo.Tools.Bash, Arvo.Tools.Edit, Arvo.Tools.Write, Arvo.Tools.Pane]
  end

  @doc "Build Arvo.Tool.spec/0 map from a Jido.Action module's `to_tool/0`."
  def spec_from_jido(module) when is_atom(module) do
    tool = module.to_tool()

    %{
      name: tool.name,
      description: tool.description,
      parameters: tool.parameters_schema
    }
  end

  @doc """
  Validate `args` via jido_action schema, then call `module.run/2`.
  Returns `{:ok, text}` | `{:error, text}` for the model.
  """
  def invoke(module, args, ctx \\ %{}) when is_atom(module) and is_map(args) do
    converted =
      if function_exported?(module, :schema, 0) do
        Jido.Action.Tool.convert_params_using_schema(stringify_keys(args), module.schema())
      else
        args
      end

    case module.validate_params(converted) do
      {:ok, params} ->
        case module.run(params, ctx || %{}) do
          {:ok, text} when is_binary(text) ->
            {:ok, text}

          {:error, text} when is_binary(text) ->
            {:error, text}

          {:ok, other} ->
            {:ok, to_string(other)}

          {:error, other} ->
            {:error, inspect(other)}

          other ->
            {:error, "tool returned unexpected result: #{inspect(other)}"}
        end

      {:error, reason} ->
        {:error, "Invalid tool arguments: #{format_validation_error(reason)}"}
    end
  end

  defp stringify_keys(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} -> {k, v}
    end)
  end

  defp format_validation_error(%{message: msg}) when is_binary(msg), do: msg
  defp format_validation_error(reason) when is_binary(reason), do: reason
  defp format_validation_error(reason), do: inspect(reason)
end
