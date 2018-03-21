defmodule CforumWeb.Api.V1.UserController do
  use CforumWeb, :controller

  def index(conn, params) do
    users =
      Cforum.Accounts.Users.list_users(search: params["s"], limit: [quantity: 20, offset: 0], order: [desc: :activity])

    render(conn, "index.json", users: users)
  end
end
