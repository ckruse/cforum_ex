defmodule CforumWeb.ErrorHandler do
  import CforumWeb.Gettext

  alias Cforum.Accounts.User
  alias CforumWeb.Views.Helpers.Path

  def unauthenticated(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, gettext("You have to be logged in to see this page!"))
    |> Plug.Conn.put_status(403)
    |> Phoenix.Controller.redirect(to: Path.session_path(conn, :new))
    |> Plug.Conn.halt()
  end

  def admin_required(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, gettext("You have to be logged in and an admin to see this page!"))
    |> Plug.Conn.put_status(403)
    |> Phoenix.Controller.redirect(to: Path.session_path(conn, :new))
    |> Plug.Conn.halt()
  end

  def access_forbidden(%Plug.Conn{assigns: %{current_user: %User{}}} = conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, gettext("You don't have access to this page!"))
    |> Plug.Conn.put_status(403)
    |> Phoenix.Controller.redirect(to: Path.session_path(conn, :new))
    |> Plug.Conn.halt()
  end

  def access_forbidden(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, gettext("You don't have access to this page!"))
    |> Plug.Conn.put_status(403)
    |> Phoenix.Controller.redirect(to: Path.session_path(conn, :new))
    |> Plug.Conn.halt()
  end

  def anonymous_required(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, gettext("You are already logged in"))
    |> Phoenix.Controller.redirect(to: Path.root_path(conn, :index))
    |> Plug.Conn.halt()
  end
end
