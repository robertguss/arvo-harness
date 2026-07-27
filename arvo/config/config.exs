import Config

# Tests and programmatic starts must not own stdin / TTY.
if config_env() == :test do
  config :arvo, start_repl: false, start_focus: false
end

