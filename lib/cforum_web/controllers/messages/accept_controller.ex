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
    {thread, message} =
      Messages.get_message_from_slug_and_mid!(
        conn.assigns[:current_forum],
        conn.assigns[:current_user],
        Threads.slug_from_params(conn.params),
        conn.params["mid"],
        message_order: uconf(conn, "sort_messages")
      )

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
