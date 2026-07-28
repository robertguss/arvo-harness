defmodule Arvo.HerdrTest do
  use ExUnit.Case, async: false

  setup do
    old = Application.get_env(:arvo, :herdr_adapter)
    {:ok, _pid} = Arvo.Herdr.Fake.start_link()
    Application.put_env(:arvo, :herdr_adapter, Arvo.Herdr.Fake)

    on_exit(fn ->
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
end
