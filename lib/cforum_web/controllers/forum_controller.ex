defmodule CforumWeb.ForumController do
  use CforumWeb, :controller

  alias Cforum.Forums.Overview

  def index(conn, _params) do
    {latest_threads, newest_thread} =
      Overview.threads_for_overview(conn.assigns[:current_user], conn.assigns[:visible_forums])

    render(conn, "index.html", newest_thread: newest_thread, latest_threads: latest_threads)
  end
end
