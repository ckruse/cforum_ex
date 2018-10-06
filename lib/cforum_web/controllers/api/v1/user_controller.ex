defmodule CforumWeb.Api.V1.UserController do
  use CforumWeb, :controller

  def index(conn, %{"ids" => ids}) do
    users = Cforum.Accounts.Users.get_users(ids, order: [desc: :activity])
    render(conn, "index.json", users: users)
  end

  def index(conn, params) do
    users =
      Cforum.Accounts.Users.list_users(
        search: params["s"],
        limit: [quantity: 20, offset: 0],
        order: [desc: :activity],
        include_self: params["self"] != "no",
        user: conn.assigns[:current_user]
      )

    render(conn, "index.json", users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Cforum.Accounts.Users.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def show_self(conn, _params) do
    render(conn, "show_self.json", user: conn.assigns.current_user)
  end

  def allowed?(conn, :show_self, _), do: signed_in?(conn)
  def allowed?(_conn, _, _), do: true
end
