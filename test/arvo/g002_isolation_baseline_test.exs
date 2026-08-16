defmodule Arvo.G002IsolationBaselineTest do
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-g002-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old_home = System.get_env("HOME")
    old_key = System.get_env("XAI_API_KEY")
    System.put_env("HOME", tmp)
    System.delete_env("XAI_API_KEY")

    on_exit(fn ->
      if old_home, do: System.put_env("HOME", old_home), else: System.delete_env("HOME")

      if old_key,
        do: System.put_env("XAI_API_KEY", old_key),
        else: System.delete_env("XAI_API_KEY")

      File.rm_rf!(tmp)
    end)

    %{tmp: tmp, ctx: %{cwd: tmp, session_id: "g002", config: %{}}}
  end

  describe "H-123 payload via Arvo.Tool.invoke on Bash and Read" do
    test "env door open: Bash printenv leaks XAI_API_KEY marker", %{ctx: ctx} do
      marker = "g002-marker-#{System.unique_integer([:positive])}"
      System.put_env("XAI_API_KEY", marker)

      assert {:ok, out} =
               Arvo.Tool.invoke(Arvo.Tools.Bash, %{command: "printenv XAI_API_KEY"}, ctx)

      assert out =~ marker, "open env door: Bash printenv leaks XAI_API_KEY (H-123)"
    end

    test "env door closed: Bash printenv does not contain marker", %{ctx: ctx} do
      marker = "g002-marker-#{System.unique_integer([:positive])}"
      System.put_env("XAI_API_KEY", marker)
      System.delete_env("XAI_API_KEY")

      assert {:ok, out} =
               Arvo.Tool.invoke(Arvo.Tools.Bash, %{command: "printenv XAI_API_KEY"}, ctx)

      refute out =~ marker, "closed env door: marker absent from Bash printenv"
    end

    test "disk door: Read of 0600 auth.json returns access_token marker", %{tmp: tmp, ctx: ctx} do
      disk_marker = "g002-marker-#{System.unique_integer([:positive])}"

      :ok =
        Arvo.Auth.Store.put("grok", %{
          "type" => "oauth",
          "access_token" => disk_marker,
          "refresh_token" => "g002-not-a-token"
        })

      path = Arvo.Auth.Store.path()
      assert path == Path.join([tmp, ".arvo", "auth.json"])
      perms = Bitwise.band(File.stat!(path).mode, 0o777)
      assert perms == 0o600, "auth.json is 0600"

      assert {:ok, out} = Arvo.Tool.invoke(Arvo.Tools.Read, %{path: path}, ctx)

      assert out =~ disk_marker,
             "same-user Read of 0600 auth.json returns access_token marker (H-123)"
    end
  end

  describe "H-121 crash via Session + bash-in-turn + cancel" do
    test "cancel mid-bash leaves Session pid and JSONL user row", %{tmp: tmp} do
      old_cwd = Application.get_env(:arvo, :cwd)
      Application.put_env(:arvo, :cwd, tmp)

      on_exit(fn ->
        if old_cwd,
          do: Application.put_env(:arvo, :cwd, old_cwd),
          else: Application.delete_env(:arvo, :cwd)
      end)

      {:ok, session_path} = Arvo.Session.open_new(tmp)
      user_row = "g002-marker-#{System.unique_integer([:positive])}"
      {:ok, _} = Arvo.Session.record_message(%{role: "user", content: user_row})

      complete_fun = fn messages, _specs, _config ->
        if Enum.any?(messages, &(Map.get(&1, :role) == "tool")) do
          {:ok, %{role: "assistant", content: "should-not-land", tool_calls: []}}
        else
          {:ok,
           %{
             role: "assistant",
             content: "",
             tool_calls: [
               %{
                 id: "g002-bash",
                 name: "bash",
                 arguments: %{"command" => "sleep 8", "timeout" => 30}
               }
             ]
           }}
        end
      end

      ctx = Arvo.TurnContext.build(cwd: tmp, tools: [Arvo.Tools.Bash])

      {:ok, task} =
        Arvo.Session.start_turn(ctx, %{complete_fun: complete_fun, max_turns: 5}, fn _ -> :ok end)

      Process.sleep(300)
      :ok = Arvo.Session.cancel_turn()
      Process.sleep(50)
      refute Process.alive?(task.pid)

      assert is_pid(Process.whereis(Arvo.Session)), "Session pid lives after cancel mid-bash"
      assert File.exists?(session_path), "JSONL file still exists after cancel mid-bash"

      entries = Arvo.Session.Store.read_all(session_path)

      assert Enum.any?(entries, &(&1["content"] == user_row)),
             "prior user row still readable after cancel mid-bash"

      refute Enum.any?(entries, &(&1["content"] == "should-not-land"))
    end
  end

  describe "H-171 orphan via Bash.run_command timeout + OS pids" do
    @tag :orphans_today
    test "orphans_today leftover bash grandchildren after Task.shutdown :brutal_kill", %{
      tmp: tmp
    } do
      id = System.unique_integer([:positive])
      tag = "g002-orphan-#{id}"
      frac = id |> rem(100_000) |> Integer.to_string() |> String.pad_leading(5, "0")
      sleep_token = "sleep 20.#{frac}"
      command = "#{sleep_token} # #{tag}"

      on_exit(fn ->
        kill_os_pids(leftover_os_pids(tag, sleep_token))
      end)

      assert {:error, :timeout} = Arvo.Tools.Bash.run_command(command, tmp, 1_000)
      Process.sleep(300)
      leftover_pids = leftover_os_pids(tag, sleep_token)
      leftover = length(leftover_pids)

      assert leftover >= 1,
             "in-VM baseline still orphans bash grandchildren (H-171)"
    end
  end

  defp leftover_os_pids(tag, sleep_token) do
    beam = :os.getpid() |> List.to_integer()

    (pids_matching(tag) ++ pids_matching(sleep_token))
    |> Enum.reject(&(&1 == beam))
    |> Enum.uniq()
  end

  defp pids_matching(pattern) do
    {out, _} = System.cmd("pgrep", ["-fl", pattern], stderr_to_stdout: true)

    out
    |> String.split("\n", trim: true)
    |> Enum.reject(&String.contains?(&1, "pgrep"))
    |> Enum.flat_map(fn line ->
      case Integer.parse(String.trim(line)) do
        {pid, _} -> [pid]
        :error -> []
      end
    end)
  end

  defp kill_os_pids(pids) do
    Enum.each(pids, fn pid ->
      _ = System.cmd("kill", ["-9", Integer.to_string(pid)], stderr_to_stdout: true)
    end)
  end
end
