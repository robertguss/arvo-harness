defmodule Arvo do
  @moduledoc """
  Arvo — personal terminal coding-agent harness.
  """

  @doc "Project directory captured at launch (`ARVO_CWD`)."
  def cwd do
    case System.get_env("ARVO_CWD") do
      nil -> File.cwd!()
      "" -> File.cwd!()
      path -> path
    end
  end
end
