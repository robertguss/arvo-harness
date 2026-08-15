defmodule Arvo.ReplTest do
  use ExUnit.Case, async: true

  test "handle_line routes non-command input to chat" do
    assert Arvo.Repl.handle_line("hello\n") == {:chat, "hello"}
  end

  test "handle_line quits on quit/exit//quit" do
    assert Arvo.Repl.handle_line("quit") == :quit
    assert Arvo.Repl.handle_line("exit\n") == :quit
    assert Arvo.Repl.handle_line("/quit") == :quit
  end

  test "handle_line continues on blank" do
    assert Arvo.Repl.handle_line("   \n") == :continue
  end

  test "handle_line routes slash commands" do
    assert Arvo.Repl.handle_line("/help") == {:slash, "help", ""}
    assert Arvo.Repl.handle_line("/model xai:g") == {:slash, "model", "xai:g"}
  end
end

