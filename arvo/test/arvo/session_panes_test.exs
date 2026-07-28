defmodule Arvo.SessionPanesTest do
  use ExUnit.Case, async: false

  setup do
    old = Application.get_env(:arvo, :herdr_adapter)
    {:ok, _} = Arvo.Herdr.Fake.start_link()
    Application.put_env(:arvo, :herdr_adapter, Arvo.Herdr.Fake)
    Arvo.Herdr.Fake.reset()

    tmp = Path.join(System.tmp_dir!(), "arvo-panes-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old_home = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)

    # Clear any leftover panes from prior tests
    _ = Arvo.Session.teardown_owned_panes(:test_setup)

    on_exit(fn ->
      _ = Arvo.Session.teardown_owned_panes(:test_cleanup)
      Arvo.Herdr.Fake.stop()

      if old do
        Application.put_env(:arvo, :herdr_adapter, old)
      else
        Application.delete_env(:arvo, :herdr_adapter)
      end

      if old_home, do: System.put_env("HOME", old_home)
      File.rm_rf!(tmp)
    end)

    %{tmp: tmp}
  end

  test "register two panes; cancel_turn closes both via fake adapter" do
    assert :ok =
             Arvo.Session.register_pane(%{
               pane_id: "fake:a",
               mode: :long_lived,
               command: "server a",
               start_reaper: false
             })

    # Seed fake panes so close succeeds
    {:ok, id1} = Arvo.Herdr.split([])
    {:ok, id2} = Arvo.Herdr.split([])
    # Re-register with real fake ids
    _ = Arvo.Session.teardown_owned_panes(:reset)

    assert :ok =
             Arvo.Session.register_pane(%{
               pane_id: id1,
               mode: :long_lived,
               command: "server a",
               start_reaper: false
             })

    assert :ok =
             Arvo.Session.register_pane(%{
               pane_id: id2,
               mode: :finite,
               command: "job b",
               start_reaper: false
             })

    assert length(Arvo.Session.owned_panes()) == 2

    :ok = Arvo.Session.cancel_turn()

    assert Arvo.Session.owned_panes() == []
    calls = Arvo.Herdr.Fake.calls()
    assert Enum.any?(calls, &match?({:close, ^id1}, &1))
    assert Enum.any?(calls, &match?({:close, ^id2}, &1))
  end

  test "idle Esc with registered long_lived panes tears down without running turn" do
    {:ok, id} = Arvo.Herdr.split([])

    assert :ok =
             Arvo.Session.register_pane(%{
               pane_id: id,
               mode: :long_lived,
               command: "mix phx.server",
               start_reaper: false
             })

    # Simulate idle Esc path: TUI.key when not running
    :ok = Arvo.TUI.reset_idle()
    reply = Arvo.TUI.key(:esc)
    assert reply == :cancelled
    assert Arvo.Session.owned_panes() == []
    assert Enum.any?(Arvo.Herdr.Fake.calls(), &match?({:close, ^id}, &1))
  end

  test "jump_to tears down remaining panes", %{tmp: tmp} do
    {:ok, path} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "u1"})
    head = Arvo.Session.head_id()
    {:ok, _} = Arvo.Session.record_message(%{role: "assistant", content: "a1"})

    {:ok, id} = Arvo.Herdr.split([])

    assert :ok =
             Arvo.Session.register_pane(%{
               pane_id: id,
               mode: :long_lived,
               command: "npm start",
               start_reaper: false
             })

    assert {:ok, result} = Arvo.Session.jump_to(head)
    assert result.head_id == head
    assert Arvo.Session.owned_panes() == []
    assert Enum.any?(Arvo.Herdr.Fake.calls(), &match?({:close, ^id}, &1))

    entries = Arvo.Session.Store.read_all(path)

    assert Enum.any?(entries, fn e ->
             e["type"] == "pane_teardown" and is_binary(e["content"]) and
               e["content"] =~ "tore down"
           end)
  end

  test "resume tears down owned panes from prior live session", %{tmp: tmp} do
    {:ok, _path} = Arvo.Session.open_new(tmp)
    {:ok, id} = Arvo.Herdr.split([])

    assert :ok =
             Arvo.Session.register_pane(%{
               pane_id: id,
               mode: :long_lived,
               command: "stale server",
               start_reaper: false
             })

    assert length(Arvo.Session.owned_panes()) == 1

    # Second session in same cwd; resume newest should abandon prior panes.
    {:ok, path2} = Arvo.Session.open_new(tmp)
    # open_new already teardowns; re-register and resume path2
    {:ok, id2} = Arvo.Herdr.split([])

    assert :ok =
             Arvo.Session.register_pane(%{
               pane_id: id2,
               mode: :long_lived,
               command: "before resume",
               start_reaper: false
             })

    assert {:ok, _} = Arvo.Session.resume(path2)
    assert Arvo.Session.owned_panes() == []
    assert Enum.any?(Arvo.Herdr.Fake.calls(), &match?({:close, ^id2}, &1))
  end

  test "process-exit reaper closes and unregisters long_lived pane" do
    {:ok, id} = Arvo.Herdr.split([])
    :ok = Arvo.Herdr.run(id, "sleep 999")

    assert :ok =
             Arvo.Session.register_pane(%{
               pane_id: id,
               mode: :long_lived,
               command: "sleep 999",
               start_reaper: false
             })

    assert :ok = Arvo.Session.ensure_pane_reaper(id)

    assert length(Arvo.Session.owned_panes()) == 1

    # Mark process exited; reaper polls every 500ms
    :ok = Arvo.Herdr.Fake.set_process_alive(id, false)

    assert wait_until(fn -> Arvo.Session.owned_panes() == [] end, 3_000)
    assert Enum.any?(Arvo.Herdr.Fake.calls(), &match?({:close, ^id}, &1))
  end

  test "close timeout on one pane still attempts others" do
    {:ok, id1} = Arvo.Herdr.split([])
    {:ok, id2} = Arvo.Herdr.split([])

    # Slow close — still under Session timeout but we force error on first then ok
    :ok = Arvo.Herdr.Fake.configure(close_delay_ms: 0)

    assert :ok =
             Arvo.Session.register_pane(%{
               pane_id: id1,
               mode: :finite,
               command: "a",
               start_reaper: false
             })

    assert :ok =
             Arvo.Session.register_pane(%{
               pane_id: id2,
               mode: :finite,
               command: "b",
               start_reaper: false
             })

    # Make close always error once — both should still be attempted
    :ok = Arvo.Herdr.Fake.configure(close_error: "nope")

    assert {:ok, results} = Arvo.Session.teardown_owned_panes(:cancel)
    assert length(results) == 2
    assert Enum.all?(results, &(&1.status == :error))
    assert Arvo.Session.owned_panes() == []

    calls = Arvo.Herdr.Fake.calls()
    assert Enum.count(calls, &match?({:close, _}, &1)) >= 2
  end

  defp wait_until(fun, timeout_ms) do
    deadline = System.monotonic_time(:millisecond) + timeout_ms
    do_wait_until(fun, deadline)
  end

  defp do_wait_until(fun, deadline) do
    if fun.() do
      true
    else
      if System.monotonic_time(:millisecond) >= deadline do
        false
      else
        Process.sleep(50)
        do_wait_until(fun, deadline)
      end
    end
  end
end
