# Small fixture for the progressive-attention stranding-trap eval.
# Agent must rename module SensorDraft to the approved name from the report.
# REQUIRED_FACT_MARKER: PAYLOAD_TOKEN_b3d7f1
defmodule SensorDraft do
  @moduledoc """
  Aggregates sensor channel readings. The module name is a placeholder; the
  approved name is published in the calibration report beside this file.
  """

  @window 16

  def window, do: @window

  def mean(readings) when is_list(readings) and readings != [] do
    Enum.sum(readings) / length(readings)
  end

  def clamp(value, low, high) when low <= high do
    value |> max(low) |> min(high)
  end
end
