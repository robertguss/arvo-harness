defmodule Arvo.SessionAuditTest do
  use ExUnit.Case, async: false

  alias Arvo.Session.Audit

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-audit-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    path = Path.join(tmp, "s.jsonl")
    File.write!(path, "")
    on_exit(fn -> File.rm_rf!(tmp) end)
    %{path: path, tmp: tmp}
  end

  test "append and list store_cold + stub_in_hot with sizes", %{path: path} do
    assert {:ok, _} =
             Audit.append(path, :store_cold, %{"id" => "c1", "size" => 9000, "tool" => "bash"})

    assert {:ok, _} = Audit.append(path, :stub_in_hot, %{"id" => "c1", "size" => 9000})

    events = Audit.list(path)
    assert length(events) == 2
    assert Enum.any?(events, &(&1["type"] == "store_cold" and &1["size"] == 9000))
    assert Enum.any?(events, &(&1["type"] == "stub_in_hot"))
    assert Enum.all?(events, &is_binary(&1["at"]))
  end

  test "envelope fields present on every line", %{path: path} do
    ctx = %{
      session_id: "sess-1",
      sequence: 0,
      attention_mode: "on",
      policy_version: "1"
    }

    assert {:ok, [ev]} =
             Audit.append_many(
               path,
               [{:store_cold, %{"id" => "c1", "size" => 100, "reason" => "size"}}],
               ctx
             )

    assert ev["schema_version"] == 1
    assert is_binary(ev["event_id"])
    assert ev["type"] == "store_cold"
    assert is_binary(ev["at"])
    assert ev["session_id"] == "sess-1"
    assert ev["sequence"] == 1
    assert ev["attention_mode"] == "on"
    assert ev["policy_version"] == "1"
    assert ev["committed"] == "committed"
    assert ev["reason_class"] == "size"
  end

  test "metrics expose full_ingest_bytes and same_path_reinvoke", %{path: path} do
    _ = Audit.append(path, :full_hot, %{"size" => 5000})
    _ = Audit.append(path, :full_hot, %{"size" => 3000})
    _ = Audit.append(path, :same_path_reinvoke, %{"path" => "/a.ex"})

    m = Audit.metrics(path)
    assert m.full_hot == 2
    assert m.full_ingest_bytes == 8000
    assert m.same_path_reinvoke == 1
    assert m.n_reexpand == 0
    assert m.b_reexpand == 0
  end

  test "metrics count committed only; abandoned excluded", %{path: path} do
    _ =
      Audit.append(path, :full_hot, %{"size" => 1000, "committed" => "committed"}, %{
        sequence: 0
      })

    _ =
      Audit.append(path, :full_hot, %{"size" => 9999, "committed" => "abandoned"}, %{
        sequence: 1
      })

    m = Audit.metrics(path)
    assert m.full_hot == 1
    assert m.full_ingest_bytes == 1000
  end

  test "reason_class maps over_cap to cap_exceeded" do
    assert Audit.normalize_reason_class(:over_cap) == "cap_exceeded"
    assert Audit.normalize_reason_class("opt_out") == "opt_out"
    assert Audit.normalize_reason_class("weird") == "unknown"
  end

  test "reexpand placeholders join second expand of same cold id", %{path: path} do
    _ = Audit.append(path, :expand, %{"id" => "c1", "size" => 100}, %{sequence: 0})
    _ = Audit.append(path, :expand, %{"id" => "c1", "size" => 50}, %{sequence: 1})
    _ = Audit.append(path, :expand, %{"id" => "c2", "size" => 10}, %{sequence: 2})

    m = Audit.metrics(path)
    assert m.expand == 3
    assert m.n_reexpand == 1
    assert m.b_reexpand == 50
  end

  describe "honesty + fixture scorers (KTD-M1)" do
    test "honesty off: treatment + full_hot passes" do
      events = [
        %{
          "type" => "session_treatment",
          "attention_mode" => "off",
          "committed" => "committed"
        },
        %{
          "type" => "full_hot",
          "size" => 50_000,
          "reason_class" => "opt_out",
          "attention_mode" => "off",
          "committed" => "committed"
        },
        %{
          "type" => "full_hot",
          "size" => 50_000,
          "reason_class" => "opt_out",
          "attention_mode" => "off",
          "committed" => "committed"
        }
      ]

      assert Audit.honesty_off?(events, 2)
      refute Audit.honesty_on?(events, 2)
      m = Audit.metrics_from_events(events)
      assert m.full_hot == 2
      assert m.stub_in_hot == 0
      assert m.full_ingest_bytes == 100_000
    end

    test "honesty on: store+stub first, reuse second" do
      events = [
        %{"type" => "session_treatment", "attention_mode" => "on", "committed" => "committed"},
        %{"type" => "store_cold", "id" => "c1", "size" => 20_000, "committed" => "committed"},
        %{
          "type" => "full_hot",
          "id" => "c1",
          "size" => 20_000,
          "reason_class" => "fidelity_retention",
          "committed" => "committed"
        },
        %{
          "type" => "reuse_cold",
          "id" => "c1",
          "size" => 20_000,
          "committed" => "committed"
        },
        %{
          "type" => "stub_in_hot",
          "id" => "c1",
          "size" => 20_000,
          "committed" => "committed"
        }
      ]

      assert Audit.honesty_on?(events, 2)
      m = Audit.metrics_from_events(events)
      assert m.stub_in_hot >= 1
      assert m.reuse_cold >= 1
      assert m.full_ingest_bytes == 20_000
      assert Audit.waste_ratio(m.full_ingest_bytes, 100_000) < 1.0
    end

    test "honesty on fails when tools ran but trail empty" do
      events = [
        %{"type" => "session_treatment", "attention_mode" => "on", "committed" => "committed"}
      ]

      refute Audit.honesty_on?(events, 1)
    end

    test "stranding_candidate when task fail + stub + no model expand" do
      events = [
        %{"type" => "stub_in_hot", "id" => "c9", "committed" => "committed"}
      ]

      assert Audit.stranding_candidate?(events,
               task_ok: false,
               cold_id: "c9",
               recovery_available: true,
               hides_required_fact: true
             )

      events2 =
        events ++
          [
            %{
              "type" => "expand",
              "id" => "c9",
              "actor" => "model",
              "committed" => "committed"
            }
          ]

      refute Audit.stranding_candidate?(events2,
               task_ok: false,
               cold_id: "c9",
               recovery_available: true,
               hides_required_fact: true
             )
    end

    test "attention_audit_error counted even when committed=failed" do
      events = [
        %{"type" => "session_treatment", "attention_mode" => "on", "committed" => "committed"},
        %{
          "type" => "attention_audit_error",
          "primary_write" => "failed",
          "committed" => "failed"
        }
      ]

      m = Audit.metrics_from_events(events)
      assert m.attention_audit_error == 1
    end

    test "attention_audit_error with committed=committed increments metrics" do
      events = [
        %{
          "type" => "attention_audit_error",
          "primary_write" => "failed",
          "committed" => "committed"
        }
      ]

      m = Audit.metrics_from_events(events)
      assert m.attention_audit_error == 1
    end

    test "stub_bytes prefer projected_bytes over original size" do
      events = [
        %{
          "type" => "stub_in_hot",
          "id" => "c1",
          "size" => 50_000,
          "original_bytes" => 50_000,
          "projected_bytes" => 200,
          "committed" => "committed"
        }
      ]

      m = Audit.metrics_from_events(events)
      assert m.stub_in_hot == 1
      assert m.stub_bytes == 200
    end

    test "warm_update alone is not projection honesty signal" do
      events = [
        %{"type" => "session_treatment", "attention_mode" => "on", "committed" => "committed"},
        %{"type" => "warm_update", "committed" => "committed"}
      ]

      refute Audit.honesty_on?(events, 1)
    end

    test "headless_on_evidence_ok fails on audit error and tools without projection" do
      tmp = Path.join(System.tmp_dir!(), "arvo-audit-headless-#{System.unique_integer([:positive])}")
      File.mkdir_p!(tmp)
      path = Path.join(tmp, "s.jsonl")
      File.write!(path, "")

      # treatment only, tools claimed via explicit n
      _ =
        Audit.append_many(
          path,
          [
            {:session_treatment,
             %{"attention_mode" => "on", "policy_version" => "1"}}
          ],
          %{session_id: "s1", sequence: 0, attention_mode: "on", committed: "committed"}
        )

      refute Audit.headless_on_evidence_ok?(path, 1)
      assert Audit.headless_on_evidence_ok?(path, 0)

      _ =
        Audit.append_many(
          path,
          [
            {:attention_audit_error,
             %{"primary_write" => "failed", "reason" => "disk full"}}
          ],
          %{session_id: "s1", sequence: 1, attention_mode: "on", committed: "committed"}
        )

      # audit error fails even with tool_results_n=0
      refute Audit.headless_on_evidence_ok?(path, 0)

      File.rm_rf!(tmp)
    end
  end

  describe "product path envelope + treatment" do
    setup do
      tmp = Path.join(System.tmp_dir!(), "arvo-audit-prod-#{System.unique_integer([:positive])}")
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

      %{tmp: tmp}
    end

    test "open_new writes session_treatment; large tool gets store+stub envelope", %{tmp: tmp} do
      {:ok, path} = Arvo.Session.open_new(tmp)
      events = Audit.list(path)
      assert Enum.any?(events, &(&1["type"] == "session_treatment"))
      st = Enum.find(events, &(&1["type"] == "session_treatment"))
      assert st["attention_mode"] == "on"
      assert is_binary(st["policy_version"])
      assert is_binary(st["treatment_assigned_at"])
      assert st["schema_version"] == 1
      assert is_integer(st["sequence"])

      meta = List.first(Arvo.Session.Store.read_all(path))
      assert meta["attention_mode"] == "on"
      assert is_binary(meta["policy_version"])
      assert is_binary(meta["treatment_assigned_at"])

      large = String.duplicate("x", 5_000)

      r =
        Arvo.Session.project_tool_result("bash", %{"command" => "cat big"}, large, false)

      assert r.action == :stub
      events = Audit.list(path)
      assert Enum.any?(events, &(&1["type"] == "store_cold"))
      assert Enum.any?(events, &(&1["type"] == "stub_in_hot"))

      stub = Enum.find(events, &(&1["type"] == "stub_in_hot"))
      assert stub["schema_version"] == 1
      assert stub["attention_mode"] == "on"
      assert stub["reason_class"] in ["size", "exception_budget"]
      assert is_integer(stub["sequence"]) and stub["sequence"] >= 2

      m = Audit.metrics(path)
      assert m.session_treatment >= 1
      assert m.store_cold >= 1
      assert m.stub_in_hot >= 1
    end

    test "treatment off emits session_treatment + full_hot opt_out projection", %{tmp: tmp} do
      Application.put_env(:arvo, :progressive_attention, false)
      {:ok, path} = Arvo.Session.open_new(tmp)

      large = String.duplicate("y", 6_000)
      r = Arvo.Session.project_tool_result("bash", %{"command" => "cat y"}, large, false)
      assert r.action == :full_hot
      assert r.content == large

      events = Audit.list(path)
      assert Audit.honesty_off?(events, 1)

      assert Enum.any?(events, fn e ->
               e["type"] == "full_hot" and e["reason_class"] == "opt_out" and
                 e["attention_mode"] == "off" and e["projected_bytes"] == 6_000 and
                 e["original_bytes"] == 6_000
             end)

      m = Audit.metrics(path)
      assert m.full_hot >= 1
      assert m.full_ingest_bytes >= 6_000
      assert m.stub_in_hot == 0
    end

    test "resume keeps metadata treatment (env flip ignored)", %{tmp: tmp} do
      Application.put_env(:arvo, :progressive_attention, false)
      {:ok, path} = Arvo.Session.open_new(tmp)
      Application.put_env(:arvo, :progressive_attention, true)

      assert {:ok, _} = Arvo.Session.resume(path)
      snap = Arvo.Session.inspect_attention()
      assert snap.attention_mode == "off"

      large = String.duplicate("z", 5_000)
      r = Arvo.Session.project_tool_result("bash", %{"command" => "cat z"}, large, false)
      assert r.action == :full_hot

      events = Audit.list(path)
      assert Enum.any?(events, &(&1["type"] == "full_hot" and &1["attention_mode"] == "off"))
    end
  end
end
