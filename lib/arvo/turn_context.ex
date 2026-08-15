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

    skills =
      Keyword.get_lazy(opts, :skills, fn ->
        plugin_skills =
          try do
            Arvo.Plugins.Registry.skills()
          rescue
            _ -> []
          catch
            _, _ -> []
          end

        user_skills =
          try do
            Arvo.Skills.discover()
          rescue
            _ -> []
          catch
            _, _ -> []
          end

        # Plugin skills first, then user ~/.arvo/skills; uniq by name
        (List.wrap(plugin_skills) ++ List.wrap(user_skills))
        |> Enum.uniq_by(fn s -> Map.get(s, :name) || Map.get(s, "name") end)
      end)

    session_id = Keyword.get(opts, :session_id, sess[:id])

    # Inject live warm work-delta into hot context under budget (R5)
    messages =
      if Keyword.get(opts, :inject_warm, true) do
        inject_warm(messages, sess)
      else
        messages
      end

    %{
      messages: messages,
      tools: tools,
      skills: skills,
      cwd: cwd,
      session_id: session_id,
      prior_len: length(messages)
    }
  end

  defp inject_warm(messages, sess) when is_list(messages) do
    warm = Map.get(sess, :warm) || Map.get(sess, "warm")

    cond do
      is_nil(warm) ->
        messages

      warm == Arvo.Session.Warm.empty() ->
        messages

      true ->
        block = Arvo.Session.Warm.format_for_hot(warm)
        # Drop any previous warm inject so we do not stack essays
        messages = Enum.reject(messages, &warm_message?/1)
        warm_msg = %{role: "system", content: block}
        # Place after leading system messages if any, else at front of product history
        insert_warm(messages, warm_msg)
    end
  rescue
    _ -> messages
  end

  defp warm_message?(%{role: role, content: content})
       when role in ["system", :system] and is_binary(content) do
    String.starts_with?(content, "[warm work-delta]")
  end

  defp warm_message?(%{"role" => role, "content" => content})
       when role in ["system", "System"] and is_binary(content) do
    String.starts_with?(content, "[warm work-delta]")
  end

  defp warm_message?(_), do: false

  defp insert_warm(messages, warm_msg) do
    {leading_system, rest} =
      Enum.split_while(messages, fn m ->
        (m[:role] || m["role"]) in ["system", :system]
      end)

    leading_system ++ [warm_msg | rest]
  end
end
