defmodule Arvo.HerdrTest do
  use ExUnit.Case, async: false

  setup do
    old = Application.get_env(:arvo, :herdr_adapter)
    # Live CLI tests cache a positive available? result; clear so Fake tests
    # are not stuck returning true for the rest of the BEAM.
    _ = Arvo.Herdr.clear_available_cache()
    {:ok, _pid} = Arvo.Herdr.Fake.start_link()
    Application.put_env(:arvo, :herdr_adapter, Arvo.Herdr.Fake)

    on_exit(fn ->
      _ = Arvo.Herdr.clear_available_cache()
      Arvo.Herdr.Fake.stop()

      if old do
        Application.put_env(:arvo, :herdr_adapter, old)
      else
        Application.delete_env(:arvo, :herdr_adapter)
      end
    end)

    :ok
  end

  test "available?/0 false when fake configured unavailable" do
    :ok = Arvo.Herdr.Fake.configure(available: false)
    refute Arvo.Herdr.available?()
  end

  test "available?/0 true when fake available" do
    :ok = Arvo.Herdr.Fake.configure(available: true)
    assert Arvo.Herdr.available?()
  end

  test "CLI available?/0 is false when HERDR_ENV unset" do
    old_env = System.get_env("HERDR_ENV")
    System.delete_env("HERDR_ENV")

    on_exit(fn ->
      if old_env, do: System.put_env("HERDR_ENV", old_env)
    end)

    refute Arvo.Herdr.CLI.available?()
  end

  test "fake split returns pane id; run/read/wait/close update state" do
    assert {:ok, id} = Arvo.Herdr.split(direction: :right, no_focus: true)
    assert is_binary(id)
    assert :ok = Arvo.Herdr.run(id, "echo hi")
    assert {:ok, text} = Arvo.Herdr.read(id, lines: 10)
    assert text =~ "echo hi" or text =~ "output"
    assert {:ok, _} = Arvo.Herdr.wait_output(id, match: "hi", timeout: 1000)
    assert :ok = Arvo.Herdr.close(id)

    panes = Arvo.Herdr.Fake.panes()
    assert panes[id].open == false
    assert panes[id].command == "echo hi"

    calls = Arvo.Herdr.Fake.calls()
    assert Enum.any?(calls, &match?({:split, _, ^id}, &1))
    assert Enum.any?(calls, &match?({:run, ^id, "echo hi"}, &1))
    assert Enum.any?(calls, &match?({:close, ^id}, &1))
  end

  test "fake close maps error without raising" do
    assert {:ok, id} = Arvo.Herdr.split([])
    :ok = Arvo.Herdr.Fake.configure(close_error: "boom close")
    assert {:error, msg} = Arvo.Herdr.close(id)
    assert msg =~ "boom"
  end

  test "CLI adapter maps non-zero exit to error without raising" do
    # Invoke CLI close against a nonexistent pane id — must return {:error, _} not raise.
    result = Arvo.Herdr.CLI.close("bogus:pane:nope")
    assert match?({:error, _}, result)
  end

  test "CLI run_argv keeps multi-word command as one argv (no bash -c split)" do
    # Regression: previous implementation passed ["bash", "-c", command] as
    # separate argv. Herdr joins with spaces → `bash -c python3 -m http.server …`
    # which only runs `python3` (REPL), dropping `-m` and later args.
    cmd = "python3 -m http.server 8765"
    args = Arvo.Herdr.CLI.run_argv("w1:p1", cmd)

    assert args == ["pane", "run", "w1:p1", cmd]
    assert length(args) == 4
    refute "bash" in args
    refute "-c" in args
    # Entire multi-word command is the last argv element, not tokenized.
    assert List.last(args) == cmd
    assert String.contains?(List.last(args), "http.server")
  end

  test "CLI wait_output_argv uses wait output (not pane wait-output)" do
    # Herdr 0.7 renamed pane wait-output → wait output.
    match_args = Arvo.Herdr.CLI.wait_output_argv("w1:p1", match: "ok", timeout: 1000)
    assert match_args == ["wait", "output", "w1:p1", "--match", "ok", "--timeout", "1000"]
    refute "wait-output" in match_args
    refute "pane" in match_args

    regex_args = Arvo.Herdr.CLI.wait_output_argv("w1:p2", regex: "ARVO_.*")
    assert regex_args == ["wait", "output", "w1:p2", "--match", "ARVO_.*", "--regex"]
  end

  @tag :herdr
  test "live CLI smoke: split run read close when HERDR_ENV=1" do
    if System.get_env("HERDR_ENV") == "1" and System.find_executable("herdr") do
      Application.put_env(:arvo, :herdr_adapter, Arvo.Herdr.CLI)
      assert Arvo.Herdr.available?()
      assert {:ok, id} = Arvo.Herdr.split(direction: :right, no_focus: true)
      assert is_binary(id)
      assert :ok = Arvo.Herdr.run(id, "echo ARVO_HERDR_SMOKE")
      # Best-effort wait/read; always close.
      _ = Arvo.Herdr.wait_output(id, match: "ARVO_HERDR_SMOKE", timeout: 3000)
      _ = Arvo.Herdr.read(id, lines: 20)
      assert :ok = Arvo.Herdr.close(id)
    else
      # Skip when not inside Herdr.
      assert true
    end
  end

  @tag :herdr
  test "live CLI multi-word run preserves args after first word" do
    # Marker must appear only after python -c executes — not as a substring of
    # the typed command line (which wait_output would match even if -c never ran).
    # Old bug: bash -c python3 -c "…" → interactive python3 REPL, no marker.
    marker = "ARVO_MW_OK"
    # base64("ARVO_MW_OK") so the source command does not contain the marker.
    cmd =
      ~s|python3 -c "import base64; print(base64.b64decode('QVJWT19NV19PSw==').decode())"|

    refute String.contains?(cmd, marker)

    if System.get_env("HERDR_ENV") == "1" and System.find_executable("herdr") do
      Application.put_env(:arvo, :herdr_adapter, Arvo.Herdr.CLI)
      assert {:ok, id} = Arvo.Herdr.split(direction: :right, no_focus: true)

      try do
        assert :ok = Arvo.Herdr.run(id, cmd)

        assert {:ok, wait} =
                 Arvo.Herdr.wait_output(id, match: marker, timeout: 8000)

        matched = wait[:matched_line] || Map.get(wait, :matched_line) || ""
        text = wait[:text] || Map.get(wait, :text) || ""
        assert matched =~ marker or text =~ marker
      after
        _ = Arvo.Herdr.close(id)
      end
    else
      assert true
    end
  end
end
