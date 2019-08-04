defmodule CforumWeb.Threads.OpenCloseController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.Threads
  alias Cforum.Threads.OpenClose
  alias Cforum.Threads.ThreadHelpers
  alias CforumWeb.Views.ViewHelpers.ReturnUrl

  def open(conn, params) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        ThreadHelpers.slug_from_params(params)
      )
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    OpenClose.open_thread(conn.assigns[:current_user], thread)

    conn
    |> put_flash(:info, gettext("Thread has successfully been opened."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end

  def close(conn, params) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        ThreadHelpers.slug_from_params(params)
      )
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    OpenClose.close_thread(conn.assigns[:current_user], thread)

    conn
    |> put_flash(:info, gettext("Thread has successfully been closed."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end

  def allowed?(conn, _, _), do: Abilities.signed_in?(conn)
end
