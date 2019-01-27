defmodule CforumWeb.Messages.AcceptController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Messages, Threads}
  alias CforumWeb.Views.Helpers.ReturnUrl

  def accept(conn, params) do
    Messages.accept_message(conn.assigns.message, conn.assigns.current_user, conf(conn, "accept_value", :int))

    conn
    |> put_flash(:info, gettext("Message has successfully been accepted as a solving answer"))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread, conn.assigns.message))
  end

  def unaccept(conn, params) do
    Messages.unaccept_message(conn.assigns.message, conn.assigns.current_user)

    conn
    |> put_flash(:info, gettext("Message has successfully been unaccepted as a solving answer"))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread, conn.assigns.message))
  end

  def load_resource(conn) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, Threads.slug_from_params(conn.params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["mid"])

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(conn, :accept, msg) do
    msg = msg || conn.assigns.message
    accept?(conn, msg) && !Messages.accepted?(msg)
  end

  def allowed?(conn, :unaccept, msg) do
    msg = msg || conn.assigns.message
    accept?(conn, msg) && Messages.accepted?(msg)
  end

  def allowed?(_, _, _), do: false
end
