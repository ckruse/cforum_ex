defmodule Cforum.Web.Users.SessionController do
  use Cforum.Web, :controller

  def new(conn, _params) do
    if conn.assigns[:current_user] == nil do
      render conn, "new.html"
    else
      conn
      |> put_flash(:error, gettext("You are already logged in"))
      |> redirect(to: forum_path(conn, :index))
    end
  end

  def create(conn, %{"session" => %{"login" => user,
                                    "password" => pass,
                                    "remember_me" => remember}}) do

    case Cforum.Auth.authenticate(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        conn = case remember do
                 "true" ->
                   {:ok, token, _} = Guardian.encode_and_sign(conn.private[:guardian_default_resource], "refresh")
                   conn
                   |> put_resp_cookie("remember_me", token, max_age: 30 * 24 * 60 * 60)
                 _ ->
                   conn
               end

        conn
        |> put_flash(:info, gettext("You logged in successfully"))
        |> redirect(to: forum_path(conn, :index))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, gettext("Username or password wrong"))
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, gettext("You logged out successfully"))
    |> delete_resp_cookie("remember_me")
    |> clear_session()
    |> redirect(to: forum_path(conn, :index))
  end
end
