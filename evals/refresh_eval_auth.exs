# Refresh the stored Grok OAuth token and write an eval-only store copy with
# the refresh token stripped: the Harbor container gets an access card
# (valid ~6h), never the wallet. Usage:
#
#   mix run --no-start evals/refresh_eval_auth.exs
#   ARVO_AUTH_FILE=/tmp/arvo-eval-auth.json harbor run -c evals/jobs-config/... -y

out_path = "/tmp/arvo-eval-auth.json"

{:ok, _} = Application.ensure_all_started(:req)

creds = Arvo.Auth.Store.get("grok") || raise "no grok creds in store; run device login first"
refresh = creds["refresh_token"] || raise "no refresh_token stored"

case Arvo.Auth.DeviceFlow.refresh(refresh) do
  {:ok, t} ->
    new = %{
      "type" => "oauth",
      "access_token" => t.access_token,
      "refresh_token" => t.refresh_token,
      "expires_at" => t.expires_at,
      "token_type" => t.token_type
    }

    Arvo.Auth.Store.put("grok", new)

    stripped = %{"grok" => Map.delete(new, "refresh_token")}
    File.write!(out_path, Jason.encode!(stripped, pretty: true))
    File.chmod!(out_path, 0o600)

    valid_s = t.expires_at - System.system_time(:second)
    IO.puts("refreshed ok; access valid ~#{valid_s}s; eval copy (no refresh token) at #{out_path}")

  {:error, reason} ->
    IO.puts("REFRESH FAILED: #{inspect(reason)}")
    System.halt(1)
end
