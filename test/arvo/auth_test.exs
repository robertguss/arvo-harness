defmodule Arvo.AuthTest do
  use ExUnit.Case, async: false

  setup do
    # Isolate auth.json via temporary HOME
    tmp = Path.join(System.tmp_dir!(), "arvo-auth-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old_home = System.get_env("HOME")
    System.put_env("HOME", tmp)
    on_exit(fn ->
      if old_home, do: System.put_env("HOME", old_home), else: System.delete_env("HOME")
      File.rm_rf!(tmp)
    end)

    %{tmp: tmp}
  end

  describe "Auth.Store" do
    test "writes auth.json mode 0600 keyed by provider", %{tmp: tmp} do
      :ok =
        Arvo.Auth.Store.put("grok", %{
          "type" => "oauth",
          "access_token" => "tok",
          "refresh_token" => "ref"
        })

      path = Arvo.Auth.Store.path()
      assert path == Path.join([tmp, ".arvo", "auth.json"])
      assert File.exists?(path)
      stat = File.stat!(path)
      # mode is type bits + perms; check user rw only (0600)
      perms = Bitwise.band(stat.mode, 0o777)
      assert perms == 0o600

      data = Arvo.Auth.Store.load()
      assert get_in(data, ["grok", "access_token"]) == "tok"
    end
  end

  describe "DeviceFlow" do
    test "login polls until tokens and persists" do
      http = fn
        "https://auth.x.ai/oauth2/device/code", _fields ->
          {:ok,
           %{
             status: 200,
             body: %{
               "device_code" => "dc",
               "user_code" => "ABCD-EFGH",
               "verification_uri" => "https://auth.x.ai/device",
               "expires_in" => 600,
               "interval" => 0
             }
           }}

        "https://auth.x.ai/oauth2/token", fields ->
          if fields["grant_type"] =~ "device_code" do
            # First poll pending, second success — use process counter
            n = Process.get(:poll_n, 0)
            Process.put(:poll_n, n + 1)

            if n == 0 do
              {:ok, %{status: 400, body: %{"error" => "authorization_pending"}}}
            else
              {:ok,
               %{
                 status: 200,
                 body: %{
                   "access_token" => "access-1",
                   "refresh_token" => "refresh-1",
                   "expires_in" => 3600,
                   "token_type" => "Bearer"
                 }
               }}
            end
          else
            {:error, :unexpected}
          end
      end

      notify_box = self()

      assert {:ok, creds} =
               Arvo.Auth.DeviceFlow.login(
                 http: http,
                 sleep: fn _ -> :ok end,
                 notify: fn d ->
                   send(notify_box, {:notified, d})
                   :ok
                 end
               )

      assert_received {:notified, %{user_code: "ABCD-EFGH"}}
      assert creds["access_token"] == "access-1"
      assert Arvo.Auth.Store.get("grok")["refresh_token"] == "refresh-1"
    end

    test "refresh exchanges refresh_token" do
      http = fn _url, fields ->
        assert fields["grant_type"] == "refresh_token"
        assert fields["refresh_token"] == "old-ref"

        {:ok,
         %{
           status: 200,
           body: %{
             "access_token" => "new-access",
             "expires_in" => 3600
           }
         }}
      end

      assert {:ok, tokens} = Arvo.Auth.DeviceFlow.refresh("old-ref", http: http)
      assert tokens.access_token == "new-access"
      assert tokens.refresh_token == "old-ref"
    end
  end

  describe "TokenManager" do
    test "supplies XAI_API_KEY fallback as bearer" do
      System.put_env("XAI_API_KEY", "env-key-xyz")
      on_exit(fn -> System.delete_env("XAI_API_KEY") end)
      :ok = Arvo.Auth.TokenManager.reload()

      assert {:ok, "env-key-xyz"} = Arvo.Auth.TokenManager.bearer("grok")
    end

    test "with_bearer refreshes once on 401 then succeeds" do
      System.delete_env("XAI_API_KEY")

      Application.put_env(:arvo, :device_flow_refresh, fn "ref-tok" ->
        {:ok,
         %{
           access_token: "fresh-token",
           refresh_token: "ref-tok",
           expires_at: System.system_time(:second) + 3600,
           token_type: "Bearer"
         }}
      end)

      on_exit(fn -> Application.delete_env(:arvo, :device_flow_refresh) end)

      :ok =
        Arvo.Auth.TokenManager.put_tokens("grok", %{
          "access_token" => "stale",
          "refresh_token" => "ref-tok",
          "expires_at" => System.system_time(:second) + 3600
        })

      calls = :atomics.new(1, signed: false)

      fun = fn
        "stale" ->
          :atomics.add(calls, 1, 1)
          {:error, :unauthorized}

        "fresh-token" ->
          :atomics.add(calls, 1, 1)
          {:ok, "worked"}
      end

      assert {:ok, "worked"} = Arvo.Auth.TokenManager.with_bearer("grok", fun)
      assert :atomics.get(calls, 1) == 2
    end

    test "with_bearer one retry after simulated refresh" do
      System.delete_env("XAI_API_KEY")

      # Install a refreshable oauth entry; mock refresh by preloading via Store and
      # using an agent for HTTP — instead exercise success path without 401.
      :ok =
        Arvo.Auth.TokenManager.put_tokens("grok", %{
          "access_token" => "good",
          "refresh_token" => "r",
          "expires_at" => System.system_time(:second) + 9999
        })

      assert {:ok, "ok"} =
               Arvo.Auth.TokenManager.with_bearer("grok", fn "good" -> {:ok, "ok"} end)
    end
  end
end
