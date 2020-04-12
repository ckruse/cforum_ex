defmodule CforumWeb.Api.V1.UserController do
  use CforumWeb, :controller

  alias Cforum.Users
  alias Cforum.MessagesUsers

  def index(conn, %{"ids" => ids}) do
    users = Cforum.Users.get_users(ids, order: [desc: :activity])
    render(conn, "index.json", users: users)
  end

  def index(conn, params) do
    users =
      Cforum.Users.list_users(
        search: params["s"],
        limit: [quantity: 20, offset: 0],
        order: [desc: :activity],
        include_self: params["self"] != "no",
        prefix: params["prefix"] == "yes",
        user: conn.assigns[:current_user]
      )

    render(conn, "index.json", users: users)
  end

  def show(conn, %{"id" => id}) do
    if !Regex.match?(~r/^\d+$/, id),
      do: raise(Cforum.Errors.NotFoundError, conn: conn)

    user = Cforum.Users.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def activity(conn, %{"id" => id}) do
    if !Regex.match?(~r/^\d+$/, id),
      do: raise(Cforum.Errors.NotFoundError, conn: conn)

    user = Users.get_user!(id)

    forum_ids = Enum.map(conn.assigns[:visible_forums], & &1.forum_id)
    messages_by_months = MessagesUsers.count_messages_for_user_by_month(user, forum_ids)
    render(conn, "activity.json", activity: messages_by_months)
  end

  def allowed?(_conn, _, _), do: true
end
