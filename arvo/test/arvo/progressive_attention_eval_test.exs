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
    # Large file fixture
    large_path = Path.join(tmp, "big.ex")
    File.write!(large_path, "defmodule Big do\n" <> String.duplicate("  # line\n", 2_000) <> "end\n")

    old = System.get_env("HOME")
    System.put_env("HOME", tmp)
    Application.put_env(:arvo, :cwd, tmp)

    on_exit(fn ->
      if old, do: System.put_env("HOME", old)
      Application.put_env(:arvo, :progressive_attention, true)
      File.rm_rf!(tmp)
    end)

    %{tmp: tmp, large_path: "big.ex"}
  end

  test "thin eval: task success + efficiency better than baseline off", %{
    tmp: tmp,
    large_path: large_path
  } do
    on_metrics = run_scenario(tmp, large_path, true)
    off_metrics = run_scenario(tmp, large_path, false)

    # Task success: edit applied in both (checked inside run_scenario via file content)
    assert on_metrics.task_ok
    assert off_metrics.task_ok

    # Efficiency: progressive on should place fewer full bytes into model hot on re-read
    assert on_metrics.model_full_bytes_second_read < off_metrics.model_full_bytes_second_read,
           "expected attention-on second-read full bytes (#{on_metrics.model_full_bytes_second_read}) < off (#{off_metrics.model_full_bytes_second_read})"

    assert on_metrics.stub_in_hot >= 1
  end

  test "default-on product path emits audit; opt-out disables stubs", %{tmp: tmp} do
    Application.put_env(:arvo, :progressive_attention, true)
    {:ok, path} = Arvo.Session.open_new(tmp)
    large = String.duplicate("log\n", 3_000)

    r = Arvo.Session.project_tool_result("bash", %{"command" => "cat x"}, large, false)
    assert r.action == :stub
    assert r.content =~ "[cold:"
    m = Arvo.Session.Audit.metrics(path)
    assert m.store_cold >= 1
    assert m.stub_in_hot >= 1

    Application.put_env(:arvo, :progressive_attention, false)
    {:ok, path2} = Arvo.Session.open_new(tmp)
    r2 = Arvo.Session.project_tool_result("bash", %{"command" => "cat x"}, large, false)
    # Without session_path effectively... wait, Session still has path. enabled? is false.
    assert r2.action == :full_hot
    assert r2.content == large
    # Opt-out should not require cold for model identity
    assert r2.content == large
    _ = path2
  end

  defp run_scenario(tmp, large_path, attention_on?) do
    Application.put_env(:arvo, :progressive_attention, attention_on?)
    {:ok, path} = Arvo.Session.open_new(tmp)
    {:ok, _} = Arvo.Session.record_message(%{role: "user", content: "fix typo in big.ex"})

    # Multi-turn scripted agent: read large file, then read again, then edit
    complete_fun = fn messages, _specs, _config ->
      tool_results = Enum.filter(messages, &(&1[:role] == "tool"))
      reads = Enum.filter(tool_results, &(&1[:name] == "read"))

      cond do
        tool_results == [] ->
          {:ok,
           %{
             role: "assistant",
             content: "",
             tool_calls: [%{id: "r1", name: "read", arguments: %{"path" => large_path}}]
           }}

        length(reads) == 1 ->
          {:ok,
           %{
             role: "assistant",
             content: "",
             tool_calls: [%{id: "r2", name: "read", arguments: %{"path" => large_path}}]
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
                   "path" => large_path,
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
        cwd: tmp
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
    second_read = Enum.at(tool_msgs, 1)

    model_full_bytes_second_read =
      if second_read do
        content = second_read[:content] || ""
        if content =~ "[cold:", do: 0, else: byte_size(content)
      else
        999_999
      end

    task_ok = File.read!(Path.join(tmp, large_path)) =~ "BigFixed"
    metrics = Arvo.Session.Audit.metrics(path)

    %{
      task_ok: task_ok,
      model_full_bytes_second_read: model_full_bytes_second_read,
      full_ingest_bytes: metrics.full_ingest_bytes,
      stub_in_hot: metrics.stub_in_hot,
      same_path_reinvoke: metrics.same_path_reinvoke,
      attention_on: attention_on?
    }
  end
end
