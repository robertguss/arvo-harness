defmodule Fff.Native do
  @moduledoc """
  Rustler NIF for fff search (`native/fff_search`). Loaded by the fff plugin tool.
  """
  use Rustler, otp_app: :arvo, crate: "fff_search"

  # NIF: search(pattern, path) -> {:ok, text} | {:error, reason}
  def search(_pattern, _path), do: :erlang.nif_error(:nif_not_loaded)
end
