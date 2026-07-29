defmodule Arvo.HeadlessChatTest do
  @moduledoc """
  KTD-H1 / KTD-D1: headless arvo-chat product path with fake complete_fun.
  """
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-headless-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)

    old_home = System.get_env("HOME")
    old_cwd = Application.get_env(:arvo, :cwd)
    old_pa = Application.get_env(:arvo, :progressive_attention)
    old_halt = Application.get_env(:arvo, :cli_halt)
    old_cf = Application.get_env(:arvo, :complete_fun)
    old_headless = Application.get_env(:arvo, :headless)
    old_sys_pa = System.get_env("ARVO_PROGRESSIVE_ATTENTION")
    old_sys_hl = System.get_env("ARVO_HEADLESS")
    old_sys_cwd = System.get_env("ARVO_CWD")
    old_sys_prompt = System.get_env("ARVO_PROMPT")
    old_sys_mode = System.get_env("ARVO_MODE")

    System.put_env("HOME", tmp)
    System.delete_env("ARVO_CWD")
    System.delete_env("ARVO_PROMPT")
    Application.put_env(:arvo, :cwd, tmp)
    Application.put_env(:arvo, :cli_halt, false)
    Application.put_env(:arvo, :progressive_attention, true)

    on_exit(fn ->
      if old_home, do: System.put_env("HOME", old_home), else: System.delete_env("HOME")
      if old_cwd, do: Application.put_env(:arvo, :cwd, old_cwd)
      if is_nil(old_pa), do: Application.delete_env(:arvo, :progressive_attention), else: Application.put_env(:arvo, :progressive_attention, old_pa)
      if is_nil(old_halt), do: Application.delete_env(:arvo, :cli_halt), else: Application.put_env(:arvo, :cli_halt, old_halt)
      if is_nil(old_cf), do: Application.delete_env(:arvo, :complete_fun), else: Application.put_env(:arvo, :complete_fun, old_cf)
      if is_nil(old_headless), do: Application.delete_env(:arvo, :headless), else: Application.put_env(:arvo, :headless, old_headless)

      if old_sys_pa,
        do: System.put_env("ARVO_PROGRESSIVE_ATTENTION", old_sys_pa),
        else: System.delete_env("ARVO_PROGRESSIVE_ATTENTION")

      if old_sys_hl,
        do: System.put_env("ARVO_HEADLESS", old_sys_hl),
        else: System.delete_env("ARVO_HEADLESS")

      if old_sys_cwd, do: System.put_env("ARVO_CWD", old_sys_cwd), else: System.delete_env("ARVO_CWD")
      if old_sys_prompt, do: System.put_env("ARVO_PROMPT", old_sys_prompt), else: System.delete_env("ARVO_PROMPT")
      if old_sys_mode, do: System.put_env("ARVO_MODE", old_sys_mode), else: System.delete_env("ARVO_MODE")

      File.rm_rf!(tmp)
    end)

    %{tmp: tmp}
  end

  test "parse_args requires cwd and prompt" do
    System.delete_env("ARVO_CWD")
    System.delete_env("ARVO_PROMPT")
    System.delete_env("ARVO_ATTENTION")
    System.delete_env("ARVO_PROGRESSIVE_ATTENTION")

    assert {:error, _} = Arvo.CLI.Chat.parse_args([])
    assert {:error, _} = Arvo.CLI.Chat.parse_args(["--cwd", "/tmp"])
    assert {:error, _} = Arvo.CLI.Chat.parse_args(["--prompt", "hi"])

    assert {:ok, opts} =
             Arvo.CLI.Chat.parse_args(["--cwd", "/tmp", "--prompt", "hi", "--attention", "off"])

    assert opts.attention == "off"
    assert opts.cwd == Path.expand("/tmp")
  end

  test "missing cwd directory exits 1", %{tmp: tmp} do
    missing = Path.join(tmp, "no-such-dir-#{System.unique_integer([:positive])}")

    code =
      Arvo.CLI.Chat.main_no_halt([
        "--cwd",
        missing,
        "--prompt",
        "hello"
      ])

    assert code == 1
  end

  test "happy path: session + audit + treatment with fake complete_fun", %{tmp: tmp} do
    work = Path.join(tmp, "work")
    File.mkdir_p!(work)

    complete_fun = fn _messages, _specs, _config ->
      {:ok, %{role: "assistant", content: "done", tool_calls: []}}
    end

    code =
      Arvo.CLI.Chat.run(%{
        cwd: work,
        prompt: "Say done when ready",
        attention: "on",
        max_turns: 3,
        timeout_sec: 30,
        complete_fun: complete_fun
      })

    assert code == 0

    sess = Arvo.Session.get()
    assert is_binary(sess.path)
    assert File.regular?(sess.path)

    audit_path = Arvo.Session.Audit.path(sess.path)
    assert File.regular?(audit_path), "expected audit at #{audit_path}"

    events = Arvo.Session.Audit.list(sess.path)
    assert Enum.any?(events, &(&1["type"] == "session_treatment"))
    assert Enum.any?(events, &(&1["attention_mode"] == "on"))
    assert Enum.all?(events, &(&1["schema_version"] == 1))
  end

  test "attention off still writes session_treatment + full_hot when tools run", %{tmp: tmp} do
    work = Path.join(tmp, "off-work")
    File.mkdir_p!(work)
    File.write!(Path.join(work, "note.txt"), "hello off")

    complete_fun = fn messages, _specs, _config ->
      tools = Enum.filter(messages, &((&1[:role] || &1["role"]) == "tool"))

      if tools == [] do
        {:ok,
         %{
           role: "assistant",
           content: "",
           tool_calls: [%{id: "r1", name: "read", arguments: %{"path" => "note.txt"}}]
         }}
      else
        {:ok, %{role: "assistant", content: "ok", tool_calls: []}}
      end
    end

    code =
      Arvo.CLI.Chat.run(%{
        cwd: work,
        prompt: "read note",
        attention: "off",
        max_turns: 5,
        timeout_sec: 30,
        complete_fun: complete_fun
      })

    assert code == 0
    path = Arvo.Session.get().path
    events = Arvo.Session.Audit.list(path)
    assert Enum.any?(events, &(&1["type"] == "session_treatment"))
    assert Enum.any?(events, &(&1["attention_mode"] == "off"))
    assert Enum.any?(events, &(&1["type"] == "full_hot"))
  end

  test "progressive attention on stubs large tool result; RecallEvidence in registry", %{tmp: tmp} do
    work = Path.join(tmp, "stub-work")
    File.mkdir_p!(work)
    large = String.duplicate("# line\n", 3_000)
    File.write!(Path.join(work, "big.txt"), large)
    assert byte_size(large) > 4_000

    assert Arvo.Tools.RecallEvidence in Arvo.Tool.core_tools()

    complete_fun = fn messages, _specs, _config ->
      tools = Enum.filter(messages, &((&1[:role] || &1["role"]) == "tool"))

      if tools == [] do
        {:ok,
         %{
           role: "assistant",
           content: "",
           tool_calls: [%{id: "r1", name: "read", arguments: %{"path" => "big.txt"}}]
         }}
      else
        content =
          tools
          |> List.last()
          |> then(fn m -> m[:content] || m["content"] || "" end)

        # Large read should be stubbed under attention-on
        assert content =~ "[cold:" or byte_size(content) < byte_size(large)
        {:ok, %{role: "assistant", content: "stubbed ok", tool_calls: []}}
      end
    end

    code =
      Arvo.CLI.Chat.run(%{
        cwd: work,
        prompt: "read big.txt",
        attention: "on",
        max_turns: 5,
        timeout_sec: 30,
        complete_fun: complete_fun
      })

    assert code == 0
    path = Arvo.Session.get().path
    m = Arvo.Session.Audit.metrics(path)
    assert m.session_treatment >= 1
    assert m.stub_in_hot >= 1 or m.store_cold >= 1
  end

  test "provider failure exits 2", %{tmp: tmp} do
    work = Path.join(tmp, "fail-work")
    File.mkdir_p!(work)

    complete_fun = fn _m, _s, _c ->
      {:error, "provider boom"}
    end

    code =
      Arvo.CLI.Chat.run(%{
        cwd: work,
        prompt: "hi",
        attention: "on",
        max_turns: 2,
        timeout_sec: 15,
        complete_fun: complete_fun
      })

    assert code == 2
  end

  test "max turns exits 4", %{tmp: tmp} do
    work = Path.join(tmp, "max-work")
    File.mkdir_p!(work)
    File.write!(Path.join(work, "a.txt"), "x")

    complete_fun = fn _messages, _specs, _config ->
      {:ok,
       %{
         role: "assistant",
         content: "",
         tool_calls: [%{id: "r#{System.unique_integer([:positive])}", name: "read", arguments: %{"path" => "a.txt"}}]
       }}
    end

    code =
      Arvo.CLI.Chat.run(%{
        cwd: work,
        prompt: "loop",
        attention: "on",
        max_turns: 2,
        timeout_sec: 30,
        complete_fun: complete_fun
      })

    assert code == 4
  end

  test "tool_abort classifies as exit 3", %{tmp: tmp} do
    work = Path.join(tmp, "abort-work")
    File.mkdir_p!(work)

    complete_fun = fn _m, _s, _c ->
      {:error, :tool_abort}
    end

    code =
      Arvo.CLI.Chat.run(%{
        cwd: work,
        prompt: "x",
        attention: "on",
        max_turns: 2,
        timeout_sec: 15,
        complete_fun: complete_fun
      })

    assert code == 3
  end

  test "Application.headless? detects env and does not require Focus flags" do
    System.put_env("ARVO_HEADLESS", "1")
    assert Arvo.Application.headless?()
    System.delete_env("ARVO_HEADLESS")
    Application.put_env(:arvo, :headless, true)
    assert Arvo.Application.headless?()
  end

  test "release packaging docs and overlay entry exist" do
    root = Path.expand("../../..", __DIR__) |> Path.join("..") |> Path.expand()
    # test file is arvo/test/arvo/ → arvo root is ../..
    arvo_root = Path.expand("../..", __DIR__)
    assert File.regular?(Path.join(arvo_root, "rel/RELEASE.md"))
    assert File.regular?(Path.join(arvo_root, "rel/overlays/bin/arvo-chat"))
    assert File.regular?(Path.join(arvo_root, "bin/arvo-chat"))
    mix = File.read!(Path.join(arvo_root, "mix.exs"))
    assert mix =~ "releases"
    assert mix =~ "include_erts"
    _ = root
  end

  test "timeout path returns 5 when await exceeds timeout_sec", %{tmp: tmp} do
    work = Path.join(tmp, "to-work")
    File.mkdir_p!(work)

    complete_fun = fn _m, _s, _c ->
      Process.sleep(5_000)
      {:ok, %{role: "assistant", content: "late", tool_calls: []}}
    end

    code =
      Arvo.CLI.Chat.run(%{
        cwd: work,
        prompt: "slow",
        attention: "on",
        max_turns: 2,
        timeout_sec: 1,
        complete_fun: complete_fun
      })

    assert code == 5
  end
end
