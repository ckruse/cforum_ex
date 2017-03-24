defmodule Cforum.GuardianErrorHandler do
  import Cforum.Router.Helpers
  import Cforum.Gettext

  def unauthenticated(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, gettext("You have to be logged in to see this page!"))
    |> Phoenix.Controller.redirect(to: session_path(conn, :new))
    |> Plug.Conn.halt
  end

  def admin_required(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, gettext("You have to be logged in and an admin to see this page!"))
    |> Phoenix.Controller.redirect(to: session_path(conn, :new))
    |> Plug.Conn.halt
  end

  def access_forbidden(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, gettext("You don't have access to this page!"))
    |> Phoenix.Controller.redirect(to: session_path(conn, :new))
    |> Plug.Conn.halt
  end
end
