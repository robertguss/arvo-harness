import Config

# Tests and programmatic starts must not own stdin / TTY.
if config_env() == :test do
  config :arvo,
    start_repl: false,
    start_focus: false,
    auto_resume: false,
    auto_compact: false,
    # Focus.run must not System.stop/1 during ExUnit
    halt_on_focus_quit: false
end

