defmodule Arvo.CompactionTest do
  use ExUnit.Case, async: true

  test "should_auto_compact past window-16k" do
    refute Arvo.Session.Compaction.should_auto_compact?(1000, 500_000)
    assert Arvo.Session.Compaction.should_auto_compact?(500_000 - 16_000 + 1, 500_000)
  end

  test "compact builds summary + tail and entry" do
    messages =
      for i <- 1..10 do
        %{role: "user", content: "msg#{i}", id: "id#{i}"}
      end

    result =
      Arvo.Session.Compaction.compact(messages, [],
        keep_recent_messages: 2,
        instructions: "be brief",
        summarize_fun: fn drop, instr ->
          "SUM(#{length(drop)}):#{instr}"
        end
      )

    assert result.summary =~ "SUM(8)"
    assert result.summary =~ "be brief"
    assert length(result.kept_messages) == 2
    assert result.entry["type"] == "compaction"
    assert hd(result.messages).content =~ "compacted summary"
  end

  test "length error suggests /compact" do
    assert Arvo.Session.Compaction.length_error_message() =~ "/compact"
  end
end
