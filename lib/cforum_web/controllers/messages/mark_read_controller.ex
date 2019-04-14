defmodule CforumWeb.Messages.MarkReadController do
  use CforumWeb, :controller

  alias Cforum.Forums.Messages
  alias Cforum.Forums.Threads
  alias CforumWeb.Views.Helpers.ReturnUrl

  def mark_read(conn, params) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        Threads.slug_from_params(params)
      )
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    Messages.mark_messages_read(conn.assigns[:current_user], thread.messages)

    conn
    |> put_flash(:info, gettext("Thread has successfully been marked as read."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end

  def allowed?(conn, _, _), do: Abilities.signed_in?(conn)
end
