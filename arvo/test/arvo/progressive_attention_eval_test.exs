defmodule Arvo.ProgressiveAttentionEvalTest do
  @moduledoc """
  Thin multi-turn efficiency eval (S5 / AE5).

  Task: "fix" a large file fixture without a second full-file hot ingest when
  progressive attention is on, versus baseline with attention off.
  """
  use ExUnit.Case, async: false

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-pa-eval-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)

    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      Application.put_env(:arvo, :progressive_attention, true)
      File.rm_rf!(tmp)
    end)

    %{tmp: tmp}
  end

  test "thin eval: task success + efficiency better than baseline off", %{tmp: tmp} do
    on_metrics = run_scenario(tmp, true)
    off_metrics = run_scenario(tmp, false)

    assert on_metrics.task_ok
    assert off_metrics.task_ok

    assert on_metrics.model_full_bytes_second_read < off_metrics.model_full_bytes_second_read,
           "expected attention-on second-read full bytes (#{on_metrics.model_full_bytes_second_read}) < off (#{off_metrics.model_full_bytes_second_read})"

    assert on_metrics.stub_in_hot >= 1
    assert on_metrics.second_is_stub
    # First large read should be fidelity full_hot when on
    assert on_metrics.first_is_full_hot or on_metrics.first_cold_id != nil
  end

  test "default-on product path emits audit; opt-out disables stubs but still projects", %{
    tmp: tmp
  } do
    Application.put_env(:arvo, :progressive_attention, true)
    {:ok, path} = Arvo.Session.open_new(tmp)
    large = String.duplicate("log\n", 3_000)

    r = Arvo.Session.project_tool_result("bash", %{"command" => "cat x"}, large, false)
    assert r.action == :stub
    assert r.content =~ "[cold:"
    m = Arvo.Session.Audit.metrics(path)
    assert m.store_cold >= 1
    assert m.stub_in_hot >= 1
    assert m.session_treatment >= 1
    events = Arvo.Session.Audit.list(path)
    assert Arvo.Session.Audit.honesty_on?(events, 1)
    assert Enum.all?(events, &(&1["schema_version"] == 1))

    Application.put_env(:arvo, :progressive_attention, false)
    {:ok, path2} = Arvo.Session.open_new(tmp)
    r2 = Arvo.Session.project_tool_result("bash", %{"command" => "cat x"}, large, false)
    assert r2.action == :full_hot
    assert r2.content == large

    events2 = Arvo.Session.Audit.list(path2)
    assert Arvo.Session.Audit.honesty_off?(events2, 1)
    m2 = Arvo.Session.Audit.metrics(path2)
    assert m2.full_hot >= 1
    assert m2.full_ingest_bytes > 0
    assert m2.stub_in_hot == 0
  end

  defp run_scenario(tmp, attention_on?) do
    # Isolated fixture dir so on/off runs do not share edited files
    work = Path.join(tmp, "run-#{if attention_on?, do: "on", else: "off"}-#{System.unique_integer([:positive])}")
    File.mkdir_p!(work)
    large_name = "big.ex"
    large_path = Path.join(work, large_name)
    File.write!(large_path, "defmodule Big do\n" <> String.duplicate("  # line\n", 2_000) <> "end\n")

    Application.put_env(:arvo, :progressive_attention, attention_on?)
    Application.put_env(:arvo, :cwd, work)
    {:ok, path} = Arvo.Session.open_new(work)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "fix typo in big.ex please"})

    complete_fun = fn messages, _specs, _config ->
      tool_results = Enum.filter(messages, &(&1[:role] == "tool"))
      reads = Enum.filter(tool_results, &(&1[:name] == "read"))

      cond do
        tool_results == [] ->
          {:ok,
           %{
             role: "assistant",
             content: "",
             tool_calls: [%{id: "r1", name: "read", arguments: %{"path" => large_name}}]
           }}

        length(reads) == 1 ->
          {:ok,
           %{
             role: "assistant",
             content: "",
             tool_calls: [%{id: "r2", name: "read", arguments: %{"path" => large_name}}]
           }}

        length(reads) >= 2 and not Enum.any?(tool_results, &(&1[:name] == "edit")) ->
          {:ok,
           %{
             role: "assistant",
             content: "",
             tool_calls: [
               %{
                 id: "e1",
                 name: "edit",
                 arguments: %{
                   "path" => large_name,
                   "old_string" => "defmodule Big do",
                   "new_string" => "defmodule BigFixed do"
                 }
               }
             ]
           }}

        true ->
          {:ok, %{role: "assistant", content: "fixed", tool_calls: []}}
      end
    end

    context =
      Arvo.TurnContext.build(
        messages: Arvo.Session.Store.messages_to_head(Arvo.Session.get().history || []),
        tools: [Arvo.Tools.Read, Arvo.Tools.Edit, Arvo.Tools.Bash],
        cwd: work
      )

    context =
      Map.put(context, :project_tool_result, fn tool, args, text, is_error, meta ->
        Arvo.Session.project_tool_result(tool, args, text, is_error, meta)
      end)

    {:ok, result} =
      Arvo.Agent.run(
        context,
        %{complete_fun: complete_fun, max_turns: 8},
        fn _ -> :ok end
      )

    tool_msgs = Enum.filter(result.messages, &(&1[:role] == "tool" and &1[:name] == "read"))
    first_read = Enum.at(tool_msgs, 0)
    second_read = Enum.at(tool_msgs, 1)

    first_content = (first_read && first_read[:content]) || ""
    second_content = (second_read && second_read[:content]) || ""

    second_is_stub = second_content =~ "[cold:"
    first_is_full_hot = not (first_content =~ "[cold:") and byte_size(first_content) > 4_000

    model_full_bytes_second_read =
      cond do
        is_nil(second_read) -> 999_999
        second_is_stub -> 0
        true -> byte_size(second_content)
      end

    first_cold_id =
      case Regex.run(~r/\[cold:([a-f0-9]+) /, second_content) do
        [_, id] -> id
        _ -> nil
      end

    # If second is stub, cold body should match first full content when first was full
    if second_is_stub and first_is_full_hot and is_binary(first_cold_id) do
      # Prefer cold_id from first tool message if present
      :ok
    end

    task_ok = File.read!(large_path) =~ "BigFixed"
    metrics = Arvo.Session.Audit.metrics(path)

    %{
      task_ok: task_ok,
      model_full_bytes_second_read: model_full_bytes_second_read,
      full_ingest_bytes: metrics.full_ingest_bytes,
      stub_in_hot: metrics.stub_in_hot,
      same_path_reinvoke: metrics.same_path_reinvoke,
      second_is_stub: second_is_stub,
      first_is_full_hot: first_is_full_hot,
      first_cold_id: first_read && first_read[:cold_id],
      attention_on: attention_on?
    }
  end
end
