defmodule Arvo.AttentionPolicyTest do
  use ExUnit.Case, async: true

  alias Arvo.Attention.Policy

  @large String.duplicate("x", 8_000)
  @small "ok\n"

  test "large bash success → stub" do
    decision =
      Policy.decide(%{
        tool: "bash",
        args: %{"command" => "cat big.log"},
        text: @large,
        is_error: false,
        retention: %{},
        budgets: %{exception_bytes: 0, exception_count: 0}
      })

    assert decision.action == :stub
    assert decision.preview_bytes > 0
    assert is_binary(decision.preview)
  end

  test "small result → full_hot" do
    decision =
      Policy.decide(%{
        tool: "bash",
        args: %{},
        text: @small,
        is_error: false,
        retention: %{},
        budgets: %{exception_bytes: 0, exception_count: 0}
      })

    assert decision.action == :full_hot
  end

  test "large error → full_hot under budget; stub when budget exhausted" do
    under =
      Policy.decide(%{
        tool: "bash",
        args: %{},
        text: @large,
        is_error: true,
        retention: %{},
        budgets: %{exception_bytes: 0, exception_count: 0}
      })

    assert under.action == :full_hot
    assert under.fidelity_exception == true

    over =
      Policy.decide(%{
        tool: "bash",
        args: %{},
        text: @large,
        is_error: true,
        retention: %{},
        budgets: %{
          exception_bytes: 200_000,
          exception_count: 50,
          max_exception_bytes: 100_000,
          max_exception_count: 10
        }
      })

    assert over.action == :stub
  end

  test "last Read of P within retention → full_hot; after TTL → stub" do
    path = "/proj/lib/foo.ex"

    within =
      Policy.decide(%{
        tool: "read",
        args: %{"path" => path},
        text: @large,
        is_error: false,
        retention: %{
          last_reads: %{path => %{turn: 1}},
          current_turn: 1,
          fidelity_ttl_turns: 3
        },
        budgets: %{exception_bytes: 0, exception_count: 0}
      })

    # First successful large read is fidelity full_hot under retention
    assert within.action == :full_hot
    assert within.fidelity_exception == true

    expired =
      Policy.decide(%{
        tool: "read",
        args: %{"path" => path},
        text: @large,
        is_error: false,
        retention: %{
          last_reads: %{path => %{turn: 1}},
          current_turn: 10,
          fidelity_ttl_turns: 3
        },
        budgets: %{exception_bytes: 0, exception_count: 0}
      })

    assert expired.action == :stub
  end

  test "edit of P invalidates fidelity; successful full-hot read clears edited sticky" do
    path = "/proj/lib/foo.ex"
    large = String.duplicate("x", 8_000)

    after_edit =
      Policy.update_retention(
        %{last_reads: %{}, edited_paths: MapSet.new(), current_turn: 1, fidelity_ttl_turns: 3},
        "edit",
        path,
        %{action: :full_hot, is_error: false},
        1
      )

    assert path in after_edit.edited_paths

    stubbed =
      Policy.decide(%{
        tool: "read",
        args: %{"path" => path},
        text: large,
        is_error: false,
        retention: after_edit,
        budgets: %{exception_bytes: 0, exception_count: 0}
      })

    assert stubbed.action == :stub

    cleared =
      Policy.update_retention(
        after_edit,
        "read",
        path,
        %{action: :full_hot, is_error: false},
        2
      )

    refute path in cleared.edited_paths
  end

  test "exception budget exceeded → prefer stub over unbounded full_hot" do
    decision =
      Policy.decide(%{
        tool: "read",
        args: %{"path" => "/a.ex"},
        text: @large,
        is_error: false,
        retention: %{
          last_reads: %{},
          current_turn: 1,
          fidelity_ttl_turns: 3
        },
        budgets: %{
          exception_bytes: 200_000,
          exception_count: 50,
          max_exception_bytes: 100_000,
          max_exception_count: 10
        }
      })

    assert decision.action == :stub
    assert decision.reason in [:exception_budget, :size]
  end

  test "expand over cap → deny with reason" do
    assert {:deny, :over_cap} =
             Policy.expand_allowed?(%{
               requested_bytes: 100_000,
               cap_bytes: 16_000,
               body_bytes: 50_000
             })

    assert {:ok, :within_cap} =
             Policy.expand_allowed?(%{
               requested_bytes: 4_000,
               cap_bytes: 16_000,
               body_bytes: 50_000
             })
  end

  test "user pin forces full_hot" do
    decision =
      Policy.decide(%{
        tool: "bash",
        args: %{},
        text: @large,
        is_error: false,
        pinned?: true,
        retention: %{},
        budgets: %{exception_bytes: 0, exception_count: 0}
      })

    assert decision.action == :full_hot
  end

  test "same-path reuse prefers cold when unchanged path already cold" do
    path = "/proj/a.ex"

    pref =
      Policy.same_path_preference(%{
        tool: "read",
        path: path,
        cold_id: "cold123",
        path_changed?: false
      })

    assert pref == :prefer_cold_stub

    pref2 =
      Policy.same_path_preference(%{
        tool: "read",
        path: path,
        cold_id: nil,
        path_changed?: false
      })

    assert pref2 == :allow_tool
  end
end
