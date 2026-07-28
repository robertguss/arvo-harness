defmodule Arvo.TUI.SlashMenuTest do
  use ExUnit.Case, async: true

  alias Arvo.TUI.SlashMenu

  test "catalog includes builtins" do
    names = Enum.map(SlashMenu.catalog(), &elem(&1, 0))
    assert "help" in names
    assert "model" in names
    assert "new" in names
    assert "quit" in names
  end

  test "filter matches name substring" do
    hits = SlashMenu.filter("mod")
    assert Enum.any?(hits, fn {n, _} -> n == "model" end)
    refute Enum.any?(hits, fn {n, _} -> n == "quit" end)
  end

  test "empty filter returns catalog" do
    assert length(SlashMenu.filter("")) == length(SlashMenu.catalog())
  end
end
