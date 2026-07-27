defmodule Arvo.TurnContext do
  @moduledoc """
  Single product assembly site for interactive turns (KTD 13).

  Builds messages/tools/skills/cwd/session_id for `Session.start_turn`.
  Skills may be empty until profile wiring lands; the key is always present.
  """

  @doc """
  Assemble product turn context from open Session (+ optional overrides).

  Options:
  - `:messages` — override history (default: session messages tip-chain / full history until HEAD)
  - `:tools` — override tools list
  - `:skills` — skill metadata list (default `[]` until U8)
  - `:cwd` — working directory
  - `:session_id` — session id
  """
  def build(opts \\ []) when is_list(opts) do
    sess = Arvo.Session.get()
    cwd = Keyword.get(opts, :cwd) || sess[:cwd] || Application.get_env(:arvo, :cwd) || Arvo.cwd()

    messages =
      Keyword.get_lazy(opts, :messages, fn ->
        # Product hot context = root → HEAD only (KTD 11). Full-file flatten is non-product.
        Arvo.Session.Store.messages_to_head(sess.history || [])
      end)

    tools =
      Keyword.get_lazy(opts, :tools, fn ->
        case Arvo.Plugins.Registry.tools() do
          list when is_list(list) and list != [] -> list
          _ -> Arvo.Tool.core_tools()
        end
      end)

    skills = Keyword.get(opts, :skills, [])
    session_id = Keyword.get(opts, :session_id, sess[:id])

    %{
      messages: messages,
      tools: tools,
      skills: skills,
      cwd: cwd,
      session_id: session_id,
      prior_len: length(messages)
    }
  end
end
