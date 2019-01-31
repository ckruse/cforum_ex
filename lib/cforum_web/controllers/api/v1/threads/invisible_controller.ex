defmodule CforumWeb.Api.V1.Threads.InvisibleController do
  use CforumWeb, :controller

  alias Cforum.Forums
  alias Cforum.Forums.Threads

  def hide(conn, _params) do
    Threads.hide_thread(conn.assigns[:current_user], conn.assigns.thread)
    json(conn, %{"status" => "ok"})
  end

  def unhide(conn, _params) do
    Threads.unhide_thread(conn.assigns[:current_user], conn.assigns.thread)
    json(conn, %{"status" => "ok"})
  end

  def load_resource(conn) do
    forum = Forums.get_forum_by_slug(conn.params["forum"])

    thread =
      Threads.get_thread_by_slug!(forum, conn.assigns[:visible_forums], conn.params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()

    conn
    |> Plug.Conn.assign(:current_forum, forum)
    |> Plug.Conn.assign(:thread, thread)
  end

  def allowed?(conn, _, _), do: signed_in?(conn)
end
