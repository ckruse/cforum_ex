defmodule CforumWeb.Threads.InvisibleController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.Threads
  alias Cforum.Threads.InvisibleThreads
  alias Cforum.Threads.ThreadHelpers
  alias Cforum.ConfigManager

  alias CforumWeb.Paginator
  alias CforumWeb.Views.ViewHelpers.ReturnUrl

  def index(conn, params) do
    page = Paginator.parse_page(params["p"]) - 1
    limit = ConfigManager.uconf(conn, "pagination", :int)
    user = conn.assigns[:current_user]
    ordering = ConfigManager.uconf(conn, "sort_threads")

    {all_threads_count, threads} =
      InvisibleThreads.list_invisible_threads(
        user,
        conn.assigns[:visible_forums],
        page: page,
        limit: limit,
        order: ordering,
        view_all: conn.assigns[:view_all]
      )

    threads =
      threads
      |> Threads.apply_user_infos(user,
        close_read_threads: ConfigManager.uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: ConfigManager.uconf(conn, "open_close_default"),
        include: [:invisible]
      )
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_trees(ConfigManager.uconf(conn, "sort_messages"))

    p = Paginator.paginate(all_threads_count, per_page: limit, page: page + 1)

    render(conn, "index.html", threads: threads, all_threads_count: all_threads_count, page: p)
  end

  def hide(conn, params) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        ThreadHelpers.slug_from_params(params)
      )
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    InvisibleThreads.hide_thread(conn.assigns[:current_user], thread)

    conn
    |> put_flash(:info, gettext("Thread has successfully been hidden."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end

  def unhide(conn, params) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        ThreadHelpers.slug_from_params(params)
      )
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.apply_user_infos(conn.assigns[:current_user], include: [:invisible])

    InvisibleThreads.unhide_thread(conn.assigns[:current_user], thread)

    conn
    |> put_flash(:info, gettext("Thread has successfully been restored."))
    |> redirect(to: Path.thread_path(conn, :index))
  end

  def allowed?(conn, :unhide, thread), do: (thread || conn.assigns[:thread]).attribs[:invisible] == true
  def allowed?(conn, :hide, thread), do: (thread || conn.assigns[:thread]).attribs[:invisible] != true
  def allowed?(conn, _, _), do: Abilities.signed_in?(conn)
end
