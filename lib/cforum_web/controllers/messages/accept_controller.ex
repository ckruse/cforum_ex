defmodule CforumWeb.Messages.AcceptController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.Threads.ThreadHelpers

  alias Cforum.Messages
  alias Cforum.Messages.MessageHelpers

  alias Cforum.ConfigManager
  alias Cforum.Helpers

  alias CforumWeb.Views.Helpers.ReturnUrl

  def accept(conn, params) do
    accept_value = ConfigManager.conf(conn, "accept_value", :int)
    Messages.accept_message(conn.assigns.message, conn.assigns.current_user, accept_value)

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
      conn.assigns[:current_forum]
      |> Threads.get_thread_by_slug!(nil, ThreadHelpers.slug_from_params(conn.params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["mid"])

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(conn, :accept, resource) do
    {thread, message} =
      case resource do
        {thread, message} -> {thread, message}
        _ -> {conn.assigns.thread, conn.assigns.message}
      end

    Helpers.present?(message.parent_id) && Abilities.accept?(conn, thread.message) && !MessageHelpers.accepted?(message) &&
      !thread.archived
  end

  def allowed?(conn, :unaccept, resource) do
    {thread, message} =
      case resource do
        {thread, message} -> {thread, message}
        _ -> {conn.assigns.thread, conn.assigns.message}
      end

    Abilities.accept?(conn, thread.message) && MessageHelpers.accepted?(message) && !thread.archived
  end

  def allowed?(_, _, _), do: false
end
