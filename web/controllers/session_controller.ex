defmodule Cforum.SessionController do
  use Cforum.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"login" => user, 
                                    "password" => pass}}) do
    case Cforum.Auth.authenticate(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
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
    |> redirect(to: forum_path(conn, :index))
  end
end
