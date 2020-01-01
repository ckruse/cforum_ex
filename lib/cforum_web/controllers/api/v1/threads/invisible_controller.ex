defmodule CforumWeb.Api.V1.Threads.InvisibleController do
  use CforumWeb, :controller

  alias Cforum.Forums
  alias Cforum.Threads
  alias Cforum.InvisibleThreads

  def hide(conn, _params) do
    InvisibleThreads.hide_thread(conn.assigns[:current_user], conn.assigns.thread)
    json(conn, %{"status" => "ok"})
  end

  def unhide(conn, _params) do
    InvisibleThreads.unhide_thread(conn.assigns[:current_user], conn.assigns.thread)
    json(conn, %{"status" => "ok"})
  end

  def load_resource(conn) do
    forum = Forums.get_forum_by_slug(conn.params["forum"])

    thread =
      forum
      |> Threads.get_thread_by_slug!(conn.assigns[:visible_forums], conn.params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
      |> Threads.apply_user_infos(conn.assigns[:current_user], include: [:invisible])

    conn
    |> Plug.Conn.assign(:current_forum, forum)
    |> Plug.Conn.assign(:thread, thread)
  end

  def allowed?(conn, action, resource), do: CforumWeb.Threads.InvisibleController.allowed?(conn, action, resource)
end
