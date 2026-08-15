defmodule ArvoTest do
  use ExUnit.Case, async: true

  test "cwd prefers ARVO_CWD over process cwd" do
    System.put_env("ARVO_CWD", "/tmp/fake-project")
    assert Arvo.cwd() == "/tmp/fake-project"
  after
    System.delete_env("ARVO_CWD")
  end

  test "cwd falls back to File.cwd! when ARVO_CWD unset" do
    System.delete_env("ARVO_CWD")
    assert Arvo.cwd() == File.cwd!()
  end
end
