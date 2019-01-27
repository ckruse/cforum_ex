defmodule CforumWeb.Api.V1.Threads.InvisibleController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads

  def hide(conn, %{"slug" => slug}) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns.current_forum, conn.assigns.visible_forums, slug)
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    Threads.hide_thread(conn.assigns[:current_user], thread)

    json(conn, %{"status" => "ok"})
  end

  def unhide(conn, %{"slug" => slug}) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns.current_forum, conn.assigns.visible_forums, slug)
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    Threads.unhide_thread(conn.assigns[:current_user], thread)

    json(conn, %{"status" => "ok"})
  end

  def allowed?(conn, _, _), do: signed_in?(conn)
end
