defmodule Arvo.Auth.DeviceFlow do
  @moduledoc """
  Grok OAuth device flow at auth.x.ai (SPEC §6). Print URL + code, poll — no callback server.
  """

  # First-party client id used by pi / grok CLI device flow.
  @client_id "b1a00492-073a-47ea-816f-4c329264a828"
  # SPEC pins api:access; include offline_access so refresh tokens work.
  @scope "api:access offline_access"
  @device_code_url "https://auth.x.ai/oauth2/device/code"
  @token_url "https://auth.x.ai/oauth2/token"
  @provider "grok"

  @doc """
  Run full device flow. Invokes `notify_fun` with
  `%{user_code, verification_uri, expires_in, interval}` once codes arrive.
  Polls until tokens or error. Persists to auth store on success.
  """
  def login(opts \\ []) do
    notify = Keyword.get(opts, :notify, &default_notify/1)
    http = Keyword.get(opts, :http, &http_post_form/2)
    poll_sleep = Keyword.get(opts, :sleep, &Process.sleep/1)

    with {:ok, device} <- request_device_code(http),
         :ok <- notify.(device),
         {:ok, tokens} <- poll_tokens(device, http, poll_sleep) do
      creds = %{
        "type" => "oauth",
        "access_token" => tokens.access_token,
        "refresh_token" => tokens.refresh_token,
        "expires_at" => tokens.expires_at,
        "token_type" => Map.get(tokens, :token_type, "Bearer")
      }

      Arvo.Auth.Store.put(@provider, creds)
      {:ok, creds}
    end
  end

  @doc "Refresh access token using stored refresh_token."
  def refresh(refresh_token, opts \\ []) when is_binary(refresh_token) do
    http = Keyword.get(opts, :http, &http_post_form/2)

    case http.(@token_url, %{
           "grant_type" => "refresh_token",
           "client_id" => @client_id,
           "refresh_token" => refresh_token
         }) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, parse_token_body(body, refresh_token)}

      {:ok, %{status: status, body: body}} ->
        {:error, "token refresh failed HTTP #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false
  def request_device_code(http) do
    case http.(@device_code_url, %{
           "client_id" => @client_id,
           "scope" => @scope
         }) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok,
         %{
           device_code: body["device_code"],
           user_code: body["user_code"],
           verification_uri:
             body["verification_uri_complete"] || body["verification_uri"],
           expires_in: body["expires_in"] || 900,
           interval: body["interval"] || 5
         }}

      {:ok, %{status: status, body: body}} ->
        {:error, "device code request failed HTTP #{status}: #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false
  def poll_tokens(device, http, sleep_fun) do
    deadline = System.monotonic_time(:second) + device.expires_in
    do_poll(device, http, sleep_fun, deadline, device.interval)
  end

  defp do_poll(device, http, sleep_fun, deadline, interval) do
    if System.monotonic_time(:second) >= deadline do
      {:error, "device authorization timed out"}
    else
      sleep_fun.(interval * 1000)

      case http.(@token_url, %{
             "grant_type" => "urn:ietf:params:oauth:grant-type:device_code",
             "client_id" => @client_id,
             "device_code" => device.device_code
           }) do
        {:ok, %{status: status, body: body}} when status in 200..299 ->
          {:ok, parse_token_body(body, nil)}

        {:ok, %{status: _status, body: body}} ->
          case body["error"] do
            "authorization_pending" ->
              do_poll(device, http, sleep_fun, deadline, interval)

            "slow_down" ->
              do_poll(device, http, sleep_fun, deadline, interval + 5)

            "access_denied" ->
              {:error, "device authorization denied"}

            "expired_token" ->
              {:error, "device code expired"}

            other ->
              {:error, "device token poll error: #{inspect(other || body)}"}
          end

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp parse_token_body(body, previous_refresh) do
    expires_in = body["expires_in"] || 3600
    refresh = body["refresh_token"] || previous_refresh

    %{
      access_token: body["access_token"],
      refresh_token: refresh,
      expires_at: System.system_time(:second) + expires_in - 60,
      token_type: body["token_type"] || "Bearer"
    }
  end

  defp default_notify(device) do
    IO.puts("""

    Grok device login
      Open: #{device.verification_uri}
      Code: #{device.user_code}
    Waiting for approval...
    """)

    :ok
  end

  defp http_post_form(url, fields) when is_map(fields) do
    body = URI.encode_query(fields)

    case Req.post(url,
           headers: [
             {"accept", "application/json"},
             {"content-type", "application/x-www-form-urlencoded"}
           ],
           body: body,
           decode_body: true
         ) do
      {:ok, %Req.Response{status: status, body: resp_body}} ->
        body_map =
          cond do
            is_map(resp_body) -> resp_body
            is_binary(resp_body) ->
              case Jason.decode(resp_body) do
                {:ok, m} -> m
                _ -> %{"raw" => resp_body}
              end

            true ->
              %{}
          end

        {:ok, %{status: status, body: body_map}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
