defmodule Arvo.Plugin do
  @moduledoc """
  Plugin behaviour (SPEC §5). Entry module by convention: `foo/` → `Foo.Plugin`.
  """

  @type manifest :: %{
          api: pos_integer(),
          tools: [module()],
          skills: [String.t()],
          children: [Supervisor.child_spec() | {module(), term()} | module()],
          commands: list(),
          hooks: list()
        }

  @callback manifest() :: manifest()
  @callback activate(ctx :: map()) :: :ok | {:error, term()}
  @callback deactivate(ctx :: map()) :: :ok | {:error, term()}

  @plugin_api 1

  def plugin_api, do: @plugin_api
end
