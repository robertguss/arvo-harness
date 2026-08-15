defmodule Arvo.RecallEvidenceTest do
  @moduledoc """
  KTD-R1: model-callable RecallEvidence recovery path.
  """
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-recall-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)
    Application.put_env(:arvo, :progressive_attention, true)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      Application.put_env(:arvo, :progressive_attention, true)
      File.rm_rf!(tmp)
    end)

    {:ok, path} = Arvo.Session.open_new(tmp)
    %{tmp: tmp, path: path}
  end

  test "core_tools registers RecallEvidence" do
    tools = Arvo.Tool.core_tools()
    assert Arvo.Tools.RecallEvidence in tools
    names = Enum.map(tools, & &1.spec().name)
    assert "RecallEvidence" in names
  end

  test "stub_content directs model to RecallEvidence and keeps /recall" do
    stub =
      Arvo.Attention.Policy.stub_content(
        %{tool: "bash", size: 9000, preview: "preview…"},
        "abc123"
      )

    assert stub =~ "RecallEvidence"
    assert stub =~ "cold_id=abc123"
    assert stub =~ "/recall abc123"
  end

  test "happy path: tool expands under actor=model; trail joins stub id", %{path: path} do
    marker = "SECRET_MARKER_#{System.unique_integer([:positive])}"
    # Past default preview (400B) so stub hides it; within expand cap so recovery works
    body = String.duplicate("noise\n", 80) <> marker <> "\n" <> String.duplicate("tail\n", 2_500)
    assert byte_size(body) > 4_000

    r = Arvo.Session.project_tool_result("bash", %{"command" => "cat secret"}, body, false)
    assert r.action == :stub
    assert r.cold_id
    refute r.content =~ marker
    assert r.content =~ "RecallEvidence"

    cold_id = r.cold_id

    assert {:ok, slice} =
             Arvo.Tool.invoke(
               Arvo.Tools.RecallEvidence,
               %{cold_id: cold_id},
               %{cwd: path, tool_call_id: "tc_recall_1"}
             )

    assert slice =~ marker
    refute slice =~ "[cold:"

    events = Arvo.Session.Audit.list(path)
    expand = Enum.find(events, &(&1["type"] == "expand"))
    stub_ev = Enum.find(events, &(&1["type"] == "stub_in_hot"))

    assert expand
    assert expand["actor"] == "model"
    assert expand["id"] == cold_id
    assert expand["tool_call_id"] == "tc_recall_1"
    assert stub_ev
    assert stub_ev["id"] == expand["id"]
  end

  test "missing cold id → denied_expand not_found + tool error", %{path: path} do
    assert {:error, msg} =
             Arvo.Tool.invoke(
               Arvo.Tools.RecallEvidence,
               %{cold_id: "deadbeefdeadbeefdeadbeefdeadbeef"},
               %{tool_call_id: "tc_missing"}
             )

    assert msg =~ "not found" or msg =~ "Not found"

    events = Arvo.Session.Audit.list(path)
    denied = Enum.find(events, &(&1["type"] == "denied_expand"))
    assert denied
    assert denied["actor"] == "model"
    assert denied["reason_class"] == "not_found" or denied["reason"] == "not_found"
  end

  test "over-cap expand → denied_expand + tool error", %{path: path} do
    body = String.duplicate("z", 20_000)
    assert {:ok, entry} = Arvo.Session.Cold.store(path, body, %{"tool" => "bash"})
    id = entry["id"]

    # Request more than policy default expand cap while body is large
    assert {:error, msg} =
             Arvo.Tool.invoke(
               Arvo.Tools.RecallEvidence,
               %{cold_id: id, max_bytes: 50_000},
               %{tool_call_id: "tc_cap"}
             )

    assert msg =~ "cap" or msg =~ "denied" or msg =~ "Expand"

    events = Arvo.Session.Audit.list(path)

    assert Enum.any?(events, fn e ->
             e["type"] == "denied_expand" and e["actor"] == "model" and
               (e["reason_class"] == "cap_exceeded" or e["reason"] == "over_cap")
           end)

    # Within-cap smaller request still succeeds
    assert {:ok, slice} =
             Arvo.Tool.invoke(Arvo.Tools.RecallEvidence, %{cold_id: id, max_bytes: 500}, %{})

    assert byte_size(slice) <= 500 + 120
  end

  test "headless recovery: stub hides marker; complete_fun calls RecallEvidence", %{tmp: tmp, path: path} do
    marker = "VERIFY_FACT_#{System.unique_integer([:positive])}"
    secret_path = Path.join(tmp, "secret.txt")
    # Past preview window, within expand cap, total > stub_bytes
    body =
      String.duplicate("# padding\n", 80) <>
        "fact=#{marker}\n" <> String.duplicate("# padding\n", 2_500)

    File.write!(secret_path, body)
    assert byte_size(body) > 4_000

    {:ok, _} =
      Arvo.Session.record_message(%{
        role: "user",
        content: "What is the fact= value in secret.txt? Use tools."
      })

    complete_fun = fn messages, _specs, _config ->
      tool_results = Enum.filter(messages, &(&1[:role] == "tool" or &1["role"] == "tool"))

      bash_or_read =
        Enum.filter(tool_results, fn m ->
          name = m[:name] || m["name"]
          name in ["bash", "read"]
        end)

      recalls =
        Enum.filter(tool_results, fn m ->
          (m[:name] || m["name"]) == "RecallEvidence"
        end)

      cond do
        tool_results == [] ->
          {:ok,
           %{
             role: "assistant",
             content: "",
             tool_calls: [
               %{id: "t_read", name: "bash", arguments: %{"command" => "cat secret.txt"}}
             ]
           }}

        length(bash_or_read) >= 1 and recalls == [] ->
          stub_msg = List.last(bash_or_read)
          content = stub_msg[:content] || stub_msg["content"] || ""

          cold_id =
            case Regex.run(~r/\[cold:([a-f0-9]+) /, content) do
              [_, id] -> id
              _ -> nil
            end

          if is_nil(cold_id) do
            {:ok, %{role: "assistant", content: "no cold id in stub", tool_calls: []}}
          else
            {:ok,
             %{
               role: "assistant",
               content: "",
               tool_calls: [
                 %{
                   id: "t_recall",
                   name: "RecallEvidence",
                   arguments: %{"cold_id" => cold_id}
                 }
               ]
             }}
          end

        length(recalls) >= 1 ->
          recall = List.last(recalls)
          content = recall[:content] || recall["content"] || ""

          if content =~ marker do
            {:ok,
             %{
               role: "assistant",
               content: "The fact is #{marker}",
               tool_calls: []
             }}
          else
            {:ok, %{role: "assistant", content: "marker missing after recall", tool_calls: []}}
          end

        true ->
          {:ok, %{role: "assistant", content: "stuck", tool_calls: []}}
      end
    end

    context =
      Arvo.TurnContext.build(
        messages: Arvo.Session.Store.messages_to_head(Arvo.Session.get().history || []),
        tools: [Arvo.Tools.Bash, Arvo.Tools.RecallEvidence],
        cwd: tmp
      )

    context =
      Map.put(context, :project_tool_result, fn tool, args, text, is_error, meta ->
        Arvo.Session.project_tool_result(tool, args, text, is_error, meta)
      end)

    {:ok, result} =
      Arvo.Agent.run(
        context,
        %{complete_fun: complete_fun, max_turns: 6},
        fn _ -> :ok end
      )

    has_marker? =
      Enum.any?(result.messages, fn m ->
        (m[:content] || m["content"] || "") =~ marker
      end)

    assert has_marker?, "expected marker in agent messages after RecallEvidence"

    events = Arvo.Session.Audit.list(path)
    stub_ev = Enum.find(events, &(&1["type"] == "stub_in_hot"))
    expand_ev = Enum.find(events, &(&1["type"] == "expand" and &1["actor"] == "model"))

    assert stub_ev
    assert expand_ev
    assert stub_ev["id"] == expand_ev["id"]
    assert expand_ev["tool_call_id"] == "t_recall"
  end
end
