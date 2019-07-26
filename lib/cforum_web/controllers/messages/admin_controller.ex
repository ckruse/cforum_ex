defmodule CforumWeb.Messages.AdminController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.Threads.ThreadHelpers
  alias Cforum.Messages

  alias Cforum.ConfigManager

  alias CforumWeb.Views.Helpers.ReturnUrl

  def delete(conn, params) do
    Messages.delete_message(conn.assigns.current_user, conn.assigns.message)

    conn
    |> put_flash(:info, gettext("Message was successfully deleted."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def restore(conn, params) do
    Messages.restore_message(conn.assigns.current_user, conn.assigns.message)

    conn
    |> put_flash(:info, gettext("Message was successfully restored."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def no_answer(conn, params) do
    Messages.flag_no_answer(conn.assigns.current_user, conn.assigns.message)

    conn
    |> put_flash(:info, gettext("Answering is now forbidden."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def answer(conn, params) do
    Messages.unflag_no_answer(conn.assigns.current_user, conn.assigns.message)

    conn
    |> put_flash(:info, gettext("Answering is now allowed."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def load_resource(conn) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, ThreadHelpers.slug_from_params(conn.params))
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["mid"])

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
    |> Plug.Conn.assign(:view_all, true)
  end

  def allowed?(conn, _, _), do: Abilities.access_forum?(conn, :moderate)
end
