defmodule Cforum.Forums.ThreadHelpers do
  alias Cforum.ConfigManager
  import Cforum.Helpers

  # "srt" as in „show read threads“
  def hide_read_threads?(conn),
    do: Cforum.ConfigManager.uconf(conn, "hide_read_threads") == "yes" && conn.params["srt"] != "yes"

  def get_ordering(conn, user) do
    cond do
      present?(conn.params["order"]) ->
        order = conn.params["order"] |> validated_ordering(conn.assigns[:current_forum])
        {user == nil, order}

      present?(conn.cookies["cf_order"]) && user == nil ->
        order = conn.cookies["order"] |> validated_ordering(conn.assigns[:current_forum])
        {false, order}

      true ->
        {false, ConfigManager.uconf(conn, "sort_threads")}
    end
  end

  defp validated_ordering(order, forum) do
    if Enum.member?(~w(ascending descending newest-first), order),
      do: order,
      else: Cforum.ConfigManager.conf(forum, "sort_threads")
  end
end
