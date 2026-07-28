defmodule Arvo.Herdr.Adapter do
  @moduledoc """
  Behaviour for Herdr pane control adapters (CLI or fake).
  """

  @type pane_id :: String.t()

  @callback available?() :: boolean()
  @callback split(opts :: keyword()) :: {:ok, pane_id()} | {:error, String.t()}
  @callback run(pane_id(), command :: String.t()) :: :ok | {:error, String.t()}
  @callback read(pane_id(), opts :: keyword()) :: {:ok, String.t()} | {:error, String.t()}
  @callback wait_output(pane_id(), opts :: keyword()) :: {:ok, map()} | {:error, String.t()}
  @callback close(pane_id()) :: :ok | {:error, String.t()}
  @callback process_info(pane_id()) :: {:ok, map()} | {:error, String.t()}
end
