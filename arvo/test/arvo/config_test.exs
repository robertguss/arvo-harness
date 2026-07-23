defmodule Arvo.ConfigTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  setup do
    tmp = Path.join(System.tmp_dir!(), "arvo-config-test-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    on_exit(fn -> File.rm_rf!(tmp) end)
    %{tmp: tmp}
  end

  test "filter_known keeps global known keys and drops unknown with warning" do
    log =
      capture_log(fn ->
        result =
          Arvo.Config.filter_known(
            %{"default_model" => "xai:grok-4.5", "mystery" => 1, "providers" => %{}},
            :global,
            "test.toml"
          )

        assert result == %{"default_model" => "xai:grok-4.5", "providers" => %{}}
      end)

    assert log =~ "unknown key"
    assert log =~ "mystery"
  end

  test "filter_known keeps only profile for project scope" do
    log =
      capture_log(fn ->
        result =
          Arvo.Config.filter_known(
            %{"profile" => "rust", "default_model" => "nope"},
            :project,
            "proj.toml"
          )

        assert result == %{"profile" => "rust"}
      end)

    assert log =~ "default_model"
  end

  test "parse_file missing file returns empty map", %{tmp: tmp} do
    assert Arvo.Config.parse_file(Path.join(tmp, "missing.toml"), :global) == %{}
  end

  test "parse_file reads TOML and filters", %{tmp: tmp} do
    path = Path.join(tmp, "config.toml")
    File.write!(path, "default_model = \"xai:test\"\nunknown = true\n")

    log =
      capture_log(fn ->
        assert Arvo.Config.parse_file(path, :global) == %{"default_model" => "xai:test"}
      end)

    assert log =~ "unknown"
  end

  test "load merges global defaults and project profile", %{tmp: tmp} do
    # Use a isolated home by writing only project config under tmp;
    # global may or may not exist — load must still return a full struct.
    project_arvo = Path.join(tmp, ".arvo")
    File.mkdir_p!(project_arvo)
    File.write!(Path.join(project_arvo, "config.toml"), "profile = \"base\"\n")

    cfg = Arvo.Config.load(tmp)
    assert cfg.cwd == tmp
    assert cfg.profile == "base"
    assert is_binary(cfg.default_model)
    assert is_map(cfg.providers)
  end
end
