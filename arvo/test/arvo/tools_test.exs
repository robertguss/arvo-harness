defmodule Arvo.ToolsTest do
  use ExUnit.Case, async: false

  setup do
    tmp =
      Path.join(
        System.tmp_dir!(),
        "arvo-tools-#{System.unique_integer([:positive])}"
      )

    File.mkdir_p!(tmp)
    on_exit(fn -> File.rm_rf!(tmp) end)
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
                   command:
                     "python3 -c \"print('x'*110000); print('TAILMARKER')\""
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
end
