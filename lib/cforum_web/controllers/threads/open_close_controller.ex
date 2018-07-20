defmodule CforumWeb.Threads.OpenCloseController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads
  alias CforumWeb.Views.Helpers.ReturnUrl

  def open(conn, params) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        conn.assigns.current_user,
        Threads.slug_from_params(params)
      )

    Threads.open_thread(conn.assigns[:current_user], thread)

    conn
    |> put_flash(:info, gettext("Thread has successfully been opened."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end

  def close(conn, params) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        conn.assigns.current_user,
        Threads.slug_from_params(params)
      )

    Threads.close_thread(conn.assigns[:current_user], thread)

    conn
    |> put_flash(:info, gettext("Thread has successfully been closed."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end

  def allowed?(conn, _, _), do: signed_in?(conn)
end
