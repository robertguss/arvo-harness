defmodule Arvo.CompletionTest do
  use ExUnit.Case, async: false

  test "config default_model is xai:grok-4.5 shape" do
    Application.put_env(:arvo, :config, %{
      default_model: "xai:grok-4.5",
      providers: %{},
      profile: nil,
      cwd: "/"
    })

    cfg = Application.get_env(:arvo, :config)
    assert cfg.default_model == "xai:grok-4.5"
  end

  test "repl handle_line routes login and chat" do
    assert Arvo.Repl.handle_line("/login") == {:slash, "login", ""}
    assert Arvo.Repl.handle_line("hello model") == {:chat, "hello model"}
    assert Arvo.Repl.handle_line("quit") == :quit
  end

  test "providers registry has grok entry" do
    entry = Arvo.Providers.Registry.get("grok")
    assert entry.prefix == "xai"
    assert entry.auth == :oauth
    assert entry.base_url =~ "api.x.ai"
  end
end
