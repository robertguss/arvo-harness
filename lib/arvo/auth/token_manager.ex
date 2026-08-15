defmodule Arvo.Auth.TokenManager do
  @moduledoc """
  GenServer: supply bearer for a provider; refresh-on-401 with one retry, then surface auth error.
  """
  use GenServer

  @provider "grok"

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "Return `{:ok, bearer}` or `{:error, reason}` for the grok/xAI provider."
  def bearer(provider \\ @provider) do
    GenServer.call(__MODULE__, {:bearer, provider})
  end

  @doc """
  Run `fun.(bearer)` in the **caller** process (not the GenServer).
  On `{:error, :unauthorized}`, refresh once, retry once, then surface auth error.
  """
  def with_bearer(provider \\ @provider, fun) when is_function(fun, 1) do
    case bearer(provider) do
      {:error, reason} ->
        {:error, reason}

      {:ok, token} ->
        case fun.(token) do
          {:ok, _} = ok ->
            ok

          {:error, :unauthorized} ->
            case GenServer.call(__MODULE__, {:refresh, provider}, 60_000) do
              {:ok, new_token} ->
                case fun.(new_token) do
                  {:ok, _} = ok -> ok
                  {:error, :unauthorized} -> {:error, "auth failed after refresh (401)"}
                  other -> other
                end

              {:error, reason} ->
                {:error, "auth refresh failed: #{format(reason)}"}
            end

          other ->
            other
        end
    end
  end

  @doc "Reload credentials from store / env into process state."
  def reload do
    GenServer.call(__MODULE__, :reload)
  end

  @doc "Put tokens into state (tests / after login)."
  def put_tokens(provider, creds) when is_map(creds) do
    GenServer.call(__MODULE__, {:put_tokens, provider, creds})
  end

  @impl true
  def init(_opts) do
    {:ok, %{tokens: load_all()}}
  end

  @impl true
  def handle_call({:bearer, provider}, _from, state) do
    case resolve_bearer(provider, state) do
      {:ok, token, state2} -> {:reply, {:ok, token}, state2}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:refresh, provider}, _from, state) do
    case try_refresh(provider, state) do
      {:ok, token, state2} -> {:reply, {:ok, token}, state2}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:reload, _from, _state) do
    {:reply, :ok, %{tokens: load_all()}}
  end

  def handle_call({:put_tokens, provider, creds}, _from, state) do
    tokens = Map.put(state.tokens, provider, normalize_creds(creds))
    {:reply, :ok, %{state | tokens: tokens}}
  end

  defp resolve_bearer(provider, state) do
    cond do
      api_key = api_key_fallback(provider) ->
        {:ok, api_key, state}

      creds = Map.get(state.tokens, provider) ->
        case creds do
          %{"access_token" => token} when is_binary(token) and token != "" ->
            if expired?(creds) do
              case try_refresh(provider, state) do
                {:ok, token, state2} -> {:ok, token, state2}
                {:error, _} = err -> err
              end
            else
              {:ok, token, state}
            end

          _ ->
            {:error, "no credentials for provider #{provider}"}
        end

      true ->
        {:error, "no credentials for provider #{provider}; set XAI_API_KEY or run /login"}
    end
  end

  defp try_refresh(provider, state) do
    creds = Map.get(state.tokens, provider) || %{}
    refresh = creds["refresh_token"]

    if is_binary(refresh) and refresh != "" do
      refresh_fun =
        Application.get_env(:arvo, :device_flow_refresh) ||
          (&Arvo.Auth.DeviceFlow.refresh/1)

      case refresh_fun.(refresh) do
        {:ok, tokens} when is_map(tokens) ->
          access = Map.get(tokens, :access_token) || Map.get(tokens, "access_token")

          new_refresh =
            Map.get(tokens, :refresh_token) || Map.get(tokens, "refresh_token") || refresh

          exp =
            Map.get(tokens, :expires_at) || Map.get(tokens, "expires_at") ||
              System.system_time(:second) + 3600

          token_type = Map.get(tokens, :token_type) || Map.get(tokens, "token_type") || "Bearer"

          new_creds = %{
            "type" => "oauth",
            "access_token" => access,
            "refresh_token" => new_refresh,
            "expires_at" => exp,
            "token_type" => token_type
          }

          Arvo.Auth.Store.put(provider, new_creds)
          state2 = %{state | tokens: Map.put(state.tokens, provider, new_creds)}
          {:ok, access, state2}

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, "no refresh_token for #{provider}"}
    end
  end

  defp api_key_fallback("grok") do
    System.get_env("XAI_API_KEY") ||
      get_in(Application.get_env(:arvo, :config) || %{}, [:providers, "xai", "api_key"]) ||
      get_in(Application.get_env(:arvo, :config) || %{}, ["providers", "xai", "api_key"])
  end

  defp api_key_fallback(_), do: nil

  defp expired?(%{"expires_at" => exp}) when is_integer(exp) do
    System.system_time(:second) >= exp
  end

  defp expired?(_), do: false

  defp load_all do
    Arvo.Auth.Store.load()
    |> Map.new(fn {k, v} -> {k, normalize_creds(v)} end)
  end

  defp normalize_creds(creds) when is_map(creds) do
    Map.new(creds, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} -> {k, v}
    end)
  end

  defp format(reason) when is_binary(reason), do: reason
  defp format(reason), do: inspect(reason)
end
