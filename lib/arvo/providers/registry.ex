defmodule Arvo.Providers.Registry do
  @moduledoc """
  Provider table: name → model prefix, auth shape, base_url (SPEC §6).
  """
  use GenServer

  @default_providers %{
    "grok" => %{
      name: "grok",
      prefix: "xai",
      auth: :oauth,
      base_url: "https://api.x.ai/v1"
    }
  }

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get(name) when is_binary(name) do
    GenServer.call(__MODULE__, {:get, name})
  end

  def list do
    GenServer.call(__MODULE__, :list)
  end

  def put(name, entry) when is_binary(name) and is_map(entry) do
    GenServer.call(__MODULE__, {:put, name, entry})
  end

  @impl true
  def init(_opts) do
    {:ok, %{providers: @default_providers}}
  end

  @impl true
  def handle_call({:get, name}, _from, state) do
    {:reply, Map.get(state.providers, name), state}
  end

  def handle_call(:list, _from, state) do
    {:reply, Map.values(state.providers), state}
  end

  def handle_call({:put, name, entry}, _from, state) do
    providers = Map.put(state.providers, name, Map.put(entry, :name, name))
    {:reply, :ok, %{state | providers: providers}}
  end
end
