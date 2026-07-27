defmodule Arvo.Session.Compaction do
  @moduledoc """
  Context compaction (SPEC §10): manual /compact + auto threshold.
  """

  @keep_recent_tokens 20_000
  @reserve_tokens 16_000
  @default_window 500_000

  def keep_recent_tokens, do: @keep_recent_tokens
  def reserve_tokens, do: @reserve_tokens

  @doc "True when cumulative tokens exceed window − 16k reserve."
  def should_auto_compact?(cumulative_tokens, window \\ @default_window) do
    cumulative_tokens > window - @reserve_tokens
  end

  @doc """
  Build compaction result from message list without calling LLM when `summarize_fun` provided.

  Returns `%{summary, first_kept_entry_id, kept_messages, entry}`.
  """
  def compact(messages, entries, opts \\ []) do
    instructions = Keyword.get(opts, :instructions)
    summarize_fun = Keyword.get(opts, :summarize_fun, &default_summarize/2)
    keep_n = Keyword.get(opts, :keep_recent_messages, 4)

    {drop, keep} = Enum.split(messages, max(length(messages) - keep_n, 0))

    summary =
      case drop do
        [] -> "No prior context to compact."
        _ -> summarize_fun.(drop, instructions)
      end

    first_kept_id =
      case keep do
        [%{id: id} | _] -> id
        [%{"id" => id} | _] -> id
        _ -> find_first_kept_entry_id(entries, keep)
      end

    entry = %{
      "type" => "compaction",
      "summary" => summary,
      "first_kept_entry_id" => first_kept_id,
      "instructions" => instructions
    }

    new_messages = [%{role: "system", content: "[compacted summary]\n" <> summary} | keep]

    %{
      summary: summary,
      first_kept_entry_id: first_kept_id,
      kept_messages: keep,
      messages: new_messages,
      entry: entry
    }
  end

  @doc "Format provider length error — prefer handoff (R16); /compact remains power path."
  def length_error_message do
    "Context length exceeded. Run /handoff for a clean session seeded with a work-delta packet (parent log intact). Power tool: /compact. (No automatic silent compact.)"
  end

  defp default_summarize(messages, instructions) do
    body =
      messages
      |> Enum.map(fn m ->
        role = m[:role] || m["role"] || "?"
        content = m[:content] || m["content"] || ""
        "#{role}: #{String.slice(to_string(content), 0, 200)}"
      end)
      |> Enum.join("\n")

    base = "Summary of earlier conversation:\n" <> body
    if instructions, do: base <> "\n\nFocus: #{instructions}", else: base
  end

  defp find_first_kept_entry_id(_entries, []), do: nil
  defp find_first_kept_entry_id(entries, keep) do
    # Prefer matching last messages to entry ids when available
    content = hd(keep)[:content] || hd(keep)["content"]

    entries
    |> Enum.find(fn e -> e["content"] == content end)
    |> case do
      %{"id" => id} -> id
      _ -> nil
    end
  end
end
