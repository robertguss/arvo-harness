defmodule Arvo.WrapperTest do
  use ExUnit.Case, async: true

  @wrapper Path.expand("../../bin/arvo", __DIR__)

  test "bin/arvo exists and is executable" do
    assert File.exists?(@wrapper)
    stat = File.stat!(@wrapper)
    # owner execute bit
    assert Bitwise.band(stat.mode, 0o100) != 0
  end

  test "bin/arvo exports ARVO_CWD and cds to checkout" do
    body = File.read!(@wrapper)
    assert body =~ "ARVO_CWD"
    assert body =~ "mix run"
    assert body =~ "mise exec"
  end

  test "mise.toml pins elixir and erlang versions" do
    mise = Path.expand("../../mise.toml", __DIR__)
    contents = File.read!(mise)
    assert contents =~ ~s(elixir = "1.20.2-otp-29")
    assert contents =~ ~s(erlang = "29.0.3")
  end
end
