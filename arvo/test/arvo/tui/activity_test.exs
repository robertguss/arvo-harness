defmodule Arvo.TUI.ActivityTest do
  use ExUnit.Case, async: true

  alias Arvo.TUI.Activity

  test "summarize bash command" do
    assert Activity.summarize("bash", %{command: "ls -la arvo"}) == "bash · ls -la arvo"
    assert Activity.summarize("bash", %{"command" => "echo hi"}) == "bash · echo hi"
  end

  test "summarize read/write/edit paths" do
    assert Activity.summarize("read", %{path: "lib/a.ex"}) == "read · lib/a.ex"
    assert Activity.summarize("write", %{"path" => "out.txt"}) == "write · out.txt"
    assert Activity.summarize("edit", %{path: "r.ex"}) == "edit · r.ex"
  end

  test "unknown tool falls back to first string arg" do
    assert Activity.summarize("search", %{query: "foo"}) == "search · foo"
  end
end
