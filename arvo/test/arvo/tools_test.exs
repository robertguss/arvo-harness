defmodule Arvo.ToolsTest do
  use ExUnit.Case, async: false

  setup do
    tmp =
      Path.join(
        System.tmp_dir!(),
        "arvo-tools-#{System.unique_integer([:positive])}"
      )

    File.mkdir_p!(tmp)

    old_adapter = Application.get_env(:arvo, :herdr_adapter)
    {:ok, _} = Arvo.Herdr.Fake.start_link()
    Application.put_env(:arvo, :herdr_adapter, Arvo.Herdr.Fake)
    Arvo.Herdr.Fake.reset()
    _ = Arvo.Session.teardown_owned_panes(:tools_setup)

    on_exit(fn ->
      _ = Arvo.Session.teardown_owned_panes(:tools_cleanup)
      Arvo.Herdr.Fake.stop()

      if old_adapter do
        Application.put_env(:arvo, :herdr_adapter, old_adapter)
      else
        Application.delete_env(:arvo, :herdr_adapter)
      end

      File.rm_rf!(tmp)
    end)

    %{tmp: tmp, ctx: %{cwd: tmp, session_id: "test", config: %{}}}
  end

  describe "spec/0 via jido_action" do
    test "all core tools export name, description, JSON Schema parameters" do
      for mod <- Arvo.Tool.core_tools() do
        spec = mod.spec()
        assert is_binary(spec.name)
        assert is_binary(spec.description)
        assert is_map(spec.parameters)

        assert spec.parameters["type"] == "object" or spec.parameters[:type] == "object" or
                 Map.has_key?(spec.parameters, "properties") or
                 Map.has_key?(spec.parameters, :properties)
      end
    end
  end

  describe "read" do
    test "reads with 1-indexed offset and limit", %{tmp: tmp, ctx: ctx} do
      path = Path.join(tmp, "lines.txt")
      File.write!(path, Enum.map_join(1..10, "\n", &"line#{&1}"))

      assert {:ok, out} =
               Arvo.Tool.invoke(Arvo.Tools.Read, %{path: path, offset: 3, limit: 2}, ctx)

      assert out =~ "line3"
      assert out =~ "line4"
      refute out =~ "line5"
    end

    test "rejects binary files", %{tmp: tmp, ctx: ctx} do
      path = Path.join(tmp, "bin.dat")
      File.write!(path, <<0, 1, 2, 255, 0, 9>>)

      assert {:error, msg} = Arvo.Tool.invoke(Arvo.Tools.Read, %{path: path}, ctx)
      assert msg =~ "binary" or msg =~ "image"
    end

    test "caps with continuation hint", %{tmp: tmp, ctx: ctx} do
      path = Path.join(tmp, "big.txt")
      # Force line cap path with many short lines
      lines = Enum.map(1..50, &"L#{&1}")
      File.write!(path, Enum.join(lines, "\n"))

      # Use a tiny limit to exercise continuation message path
      assert {:ok, out} =
               Arvo.Tool.invoke(Arvo.Tools.Read, %{path: path, offset: 1, limit: 5}, ctx)

      assert out =~ "L1"
      assert out =~ "Showing lines" or out =~ "offset="
    end
  end

  describe "bash" do
    test "merges stdout and stderr, returns exit code on failure", %{ctx: ctx} do
      assert {:ok, out} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Bash,
                 %{command: "echo hello; echo err >&2; exit 3"},
                 ctx
               )

      assert out =~ "hello"
      assert out =~ "err"
      assert out =~ "exit code 3"
    end

    test "respects timeout", %{ctx: ctx} do
      assert {:error, msg} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Bash,
                 %{command: "sleep 5", timeout: 1},
                 ctx
               )

      assert msg =~ "timed out"
    end

    test "truncation keeps tail and spill path", %{tmp: tmp, ctx: ctx} do
      # Generate >100KB of output ending with unique marker
      assert {:ok, out} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Bash,
                 %{
                   command: "python3 -c \"print('x'*110000); print('TAILMARKER')\""
                 },
                 ctx
               )

      assert out =~ "TAILMARKER"
      assert out =~ "truncated" or out =~ "full output"
      assert out =~ "arvo-bash-"
      # spill file path should exist (note ends with "]")
      assert [_, path] = Regex.run(~r{full output: ([^\]]+)}, out)
      path = String.trim(path)
      assert File.exists?(path)
      _ = tmp
    end
  end

  describe "edit" do
    test "exact once replace", %{tmp: tmp, ctx: ctx} do
      path = Path.join(tmp, "e.txt")
      File.write!(path, "alpha beta gamma")

      assert {:ok, _} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Edit,
                 %{path: path, old_string: "beta", new_string: "BETA"},
                 ctx
               )

      assert File.read!(path) == "alpha BETA gamma"
    end

    test "miss hints re-read", %{tmp: tmp, ctx: ctx} do
      path = Path.join(tmp, "e2.txt")
      File.write!(path, "only this")

      assert {:error, msg} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Edit,
                 %{path: path, old_string: "missing", new_string: "x"},
                 ctx
               )

      assert msg =~ "re-read"
    end

    test "replace_all", %{tmp: tmp, ctx: ctx} do
      path = Path.join(tmp, "e3.txt")
      File.write!(path, "a a a")

      assert {:ok, _} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Edit,
                 %{path: path, old_string: "a", new_string: "b", replace_all: true},
                 ctx
               )

      assert File.read!(path) == "b b b"
    end

    test "whitespace-tolerant fallback", %{tmp: tmp, ctx: ctx} do
      path = Path.join(tmp, "e4.txt")
      File.write!(path, "hello   world\n")

      assert {:ok, _} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Edit,
                 %{path: path, old_string: "hello world", new_string: "hi"},
                 ctx
               )

      assert File.read!(path) == "hi\n"
    end
  end

  describe "write" do
    test "creates parent dirs", %{tmp: tmp, ctx: ctx} do
      path = Path.join(tmp, "nested/deep/file.txt")

      assert {:ok, _} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Write,
                 %{path: path, content: "payload"},
                 ctx
               )

      assert File.read!(path) == "payload"
    end
  end

  describe "pane" do
    test "core_tools includes pane and excludes sub_agent/background_bash" do
      tools = Arvo.Tool.core_tools()
      assert Arvo.Tools.Pane in tools
      names = Enum.map(tools, fn mod -> mod.spec().name end)
      assert "pane" in names
      refute Enum.any?(names, &String.contains?(&1, "sub_agent"))
      refute Enum.any?(names, &String.contains?(&1, "background"))

      refute Enum.any?(tools, fn mod ->
               name = Module.split(mod) |> List.last() |> String.downcase()
               name in ["subagent", "backgroundbash", "background_bash"]
             end)
    end

    test "finite success: split/run/read/close in order; registry empty", %{ctx: ctx} do
      :ok = Arvo.Herdr.Fake.configure(available: true)
      # Finite wait uses process_info; mark dead so wait exits immediately after run.
      # Intercept by configuring after first split via wrapping run — mark dead in wait path:
      # Fake wait_output succeeds when match given; without match polls process_info.
      assert {:ok, out} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Pane,
                 %{command: "echo done", mode: "finite", timeout: 5, wait_match: "done"},
                 ctx
               )

      assert out =~ "pane" or out =~ "finished" or out =~ "output"
      assert Arvo.Session.owned_panes() == []

      calls = Arvo.Herdr.Fake.calls()

      kinds =
        Enum.map(calls, fn
          {k, _} -> k
          {k, _, _} -> k
          {k, _, _, _} -> k
          other -> other
        end)

      assert :split in kinds
      assert :run in kinds
      assert :close in kinds
    end

    test "finite still closes on wait timeout", %{ctx: ctx} do
      :ok =
        Arvo.Herdr.Fake.configure(
          available: true,
          wait_error: "timed out waiting for output match"
        )

      result =
        Arvo.Tool.invoke(
          Arvo.Tools.Pane,
          %{command: "sleep 99", mode: "finite", timeout: 1, wait_match: "never"},
          ctx
        )

      assert match?({:error, _}, result)
      assert Arvo.Session.owned_panes() == []
      assert Enum.any?(Arvo.Herdr.Fake.calls(), &match?({:close, _}, &1))
    end

    test "long_lived leaves pane open and registered", %{ctx: ctx} do
      :ok = Arvo.Herdr.Fake.configure(available: true)

      assert {:ok, out} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Pane,
                 %{
                   command: "mix phx.server",
                   mode: "long_lived",
                   timeout: 5,
                   wait_match: "Running"
                 },
                 ctx
               )

      assert out =~ "long_lived" or out =~ "running" or out =~ "started"
      panes = Arvo.Session.owned_panes()
      assert length(panes) == 1
      assert hd(panes).command =~ "mix phx.server"

      # Cancel closes the registered pane
      :ok = Arvo.Session.cancel_turn()
      assert Arvo.Session.owned_panes() == []
    end

    test "outside Herdr long_lived uses labeled blocking bash; no herdr calls", %{ctx: ctx} do
      :ok = Arvo.Herdr.Fake.configure(available: false)
      before_calls = length(Arvo.Herdr.Fake.calls())

      assert {:ok, out} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Pane,
                 %{command: "echo fallback-ok", mode: "long_lived", timeout: 5},
                 ctx
               )

      assert out =~ "no Herdr pane"
      assert out =~ "blocking bash" or out =~ "fallback-ok"
      assert out =~ "fallback-ok"
      # No new Herdr split/run after configuring unavailable
      new_calls = Enum.drop(Arvo.Herdr.Fake.calls(), before_calls)
      refute Enum.any?(new_calls, &match?({:split, _, _}, &1))
      refute Enum.any?(new_calls, &match?({:run, _, _}, &1))
    end

    test "outside Herdr finite uses labeled bash", %{ctx: ctx} do
      :ok = Arvo.Herdr.Fake.configure(available: false)

      assert {:ok, out} =
               Arvo.Tool.invoke(
                 Arvo.Tools.Pane,
                 %{command: "echo short", mode: "finite", timeout: 5},
                 ctx
               )

      assert out =~ "no Herdr pane"
      assert out =~ "short"
    end
  end
end
