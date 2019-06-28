defmodule CforumWeb.Messages.MarkReadController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.Threads.ThreadHelpers

  alias Cforum.Messages.ReadMessages
  alias Cforum.ConfigManager

  alias CforumWeb.Paginator
  alias CforumWeb.Views.Helpers.ReturnUrl

  def mark_read(conn, params) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns.current_forum,
        conn.assigns.visible_forums,
        ThreadHelpers.slug_from_params(params)
      )
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])

    ReadMessages.mark_messages_read(conn.assigns[:current_user], thread.messages)

    conn
    |> put_flash(:info, gettext("Thread has successfully been marked as read."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end

  def mark_all_read(conn, params) do
    page = Paginator.parse_page(params["p"]) - 1
    limit = ConfigManager.uconf(conn, "pagination", :int)
    use_paging = ConfigManager.uconf(conn, "use_paging") == "yes"
    user = conn.assigns[:current_user]
    {_, ordering} = ThreadHelpers.get_ordering(conn, user)

    threads =
      Threads.list_threads(conn.assigns[:current_forum], conn.assigns[:visible_forums])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.reject_invisible_threads(user, conn.assigns[:view_all])
      |> Threads.apply_user_infos(user,
        close_read_threads: ConfigManager.uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: ConfigManager.uconf(conn, "open_close_default")
      )
      |> Threads.reject_read_threads(ThreadHelpers.hide_read_threads?(conn))
      |> Threads.apply_highlights(conn)
      |> Threads.filter_wo_answer(conn.params["only_wo_answer"] != nil)
      |> Threads.sort_threads(ordering)
      |> Threads.paged_thread_list(page, limit, use_paging)
      |> Threads.build_message_trees(ConfigManager.uconf(conn, "sort_messages"))
      |> Enum.map(& &1.messages)
      |> List.flatten()

    ReadMessages.mark_messages_read(conn.assigns[:current_user], threads)

    conn
    |> put_flash(:info, gettext("All messages on this page have successfully been marked as read."))
    |> redirect(to: ReturnUrl.return_path(conn, params))
  end

  def allowed?(conn, _, _), do: Abilities.signed_in?(conn)
end
