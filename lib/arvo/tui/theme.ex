defmodule Arvo.TUI.Theme do
  @moduledoc "Intentional Focus theme tokens (variant D)."

  def dim(text), do: "\e[2m#{text}\e[0m"
  def bold(text), do: "\e[1m#{text}\e[0m"
  def error(text), do: "\e[31m#{text}\e[0m"
  def accent(text), do: "\e[36m#{text}\e[0m"
  def muted(text), do: "\e[90m#{text}\e[0m"
  def reset, do: "\e[0m"
end
