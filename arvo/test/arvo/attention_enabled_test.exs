defmodule Arvo.AttentionEnabledTest do
  use ExUnit.Case, async: false

  setup do
    old_app = Application.get_env(:arvo, :progressive_attention)
    old_sys = System.get_env("ARVO_PROGRESSIVE_ATTENTION")

    on_exit(fn ->
      if is_nil(old_app) do
        Application.delete_env(:arvo, :progressive_attention)
      else
        Application.put_env(:arvo, :progressive_attention, old_app)
      end

      if old_sys do
        System.put_env("ARVO_PROGRESSIVE_ATTENTION", old_sys)
      else
        System.delete_env("ARVO_PROGRESSIVE_ATTENTION")
      end
    end)

    :ok
  end

  test "Application false beats ambient system env on" do
    System.put_env("ARVO_PROGRESSIVE_ATTENTION", "1")
    Application.put_env(:arvo, :progressive_attention, false)

    refute Arvo.Attention.enabled?()
    assert Arvo.Attention.treatment_mode_from_env() == "off"
  end

  test "Application true beats ambient system env off" do
    System.put_env("ARVO_PROGRESSIVE_ATTENTION", "0")
    Application.put_env(:arvo, :progressive_attention, true)

    assert Arvo.Attention.enabled?()
    assert Arvo.Attention.treatment_mode_from_env() == "on"
  end

  test "system env used when Application progressive_attention is nil" do
    Application.delete_env(:arvo, :progressive_attention)
    System.put_env("ARVO_PROGRESSIVE_ATTENTION", "0")
    refute Arvo.Attention.enabled?()

    System.put_env("ARVO_PROGRESSIVE_ATTENTION", "1")
    assert Arvo.Attention.enabled?()
  end
end
