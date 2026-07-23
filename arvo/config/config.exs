import Config

# Tests and programmatic starts must not own stdin with the line REPL.
if config_env() == :test do
  config :arvo, start_repl: false
end
