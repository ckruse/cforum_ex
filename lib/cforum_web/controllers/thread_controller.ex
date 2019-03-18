defmodule CforumWeb.ThreadController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads
  alias Cforum.Forums.Messages

  def index(conn, params) do
    page = parse_page(params["p"]) - 1
    limit = uconf(conn, "pagination", :int)
    user = conn.assigns[:current_user]
    {set_order_cookie, ordering} = get_ordering(conn, user)

    threads =
      Threads.list_threads(conn.assigns[:current_forum], conn.assigns[:visible_forums])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.reject_invisible_threads(user, conn.assigns[:view_all])
      |> Threads.apply_user_infos(user,
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: uconf(conn, "open_close_default")
      )
      |> Threads.reject_read_threads(hide_read_threads?(conn))
      |> Threads.apply_highlights(conn)
      |> Threads.filter_wo_answer(conn.params["only_wo_answer"] != nil)

    all_threads_count = length(threads)

    threads =
      threads
      |> Threads.sort_threads(ordering)
      |> Threads.paged_thread_list(page, limit)
      |> Threads.build_message_trees(uconf(conn, "sort_messages"))

    p = paginate(all_threads_count, per_page: limit, page: page + 1)

    conn
    |> maybe_set_cookie(set_order_cookie, ordering)
    |> render("index.html", threads: threads, all_threads_count: all_threads_count, page: p, order: ordering)
  end

  def index_unanswered(conn, params) do
    page = parse_page(params["p"]) - 1
    limit = uconf(conn, "pagination", :int)
    user = conn.assigns[:current_user]
    {set_order_cookie, ordering} = get_ordering(conn, user)

    threads =
      Threads.list_threads(conn.assigns[:current_forum], conn.assigns[:visible_forums])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.reject_invisible_threads(user, conn.assigns[:view_all])
      |> Threads.apply_user_infos(user,
        close_read_threads: uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: uconf(conn, "open_close_default")
      )
      |> Threads.reject_read_threads(hide_read_threads?(conn))
      |> Threads.apply_highlights(conn)
      |> Threads.filter_wo_answer()

    all_threads_count = length(threads)

    threads =
      threads
      |> Threads.sort_threads(ordering)
      |> Threads.paged_thread_list(page, limit)
      |> Threads.build_message_trees(uconf(conn, "sort_messages"))

    p = paginate(all_threads_count, per_page: limit, page: page + 1)

    conn
    |> maybe_set_cookie(set_order_cookie, ordering)
    |> render("index_unanswered.html", threads: threads, all_threads_count: all_threads_count, page: p, order: ordering)
  end

  def show(conn, _params) do
    conn
    |> put_layout(false)
    |> render("thread.html")
  end

  def index_atom(conn, _params) do
    user = conn.assigns[:current_user]
    {_, ordering} = get_ordering(conn, user)

    threads =
      Threads.list_threads(conn.assigns[:current_forum], conn.assigns[:visible_forums])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.reject_invisible_threads(user, conn.assigns[:view_all])
      |> Threads.apply_user_infos(user, omit: [:open_close, :subscriptions, :interesting])
      |> Threads.reject_read_threads(hide_read_threads?(conn))
      |> Threads.apply_highlights(conn)
      |> Threads.sort_threads(ordering)
      |> Threads.build_message_trees(uconf(conn, "sort_messages"))

    render(conn, "index.atom", threads: threads)
  end

  def index_rss(conn, _params) do
    user = conn.assigns[:current_user]
    {_, ordering} = get_ordering(conn, user)

    threads =
      Threads.list_threads(conn.assigns[:current_forum], conn.assigns[:visible_forums])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.reject_invisible_threads(user, conn.assigns[:view_all])
      |> Threads.apply_user_infos(user, omit: [:open_close, :subscriptions, :interesting])
      |> Threads.reject_read_threads(hide_read_threads?(conn))
      |> Threads.apply_highlights(conn)
      |> Threads.sort_threads(ordering)
      |> Threads.build_message_trees(uconf(conn, "sort_messages"))

    render(conn, "index.rss", threads: threads)
  end

  def show_atom(conn, %{"id" => id}) do
    thread =
      Threads.get_thread!(conn.assigns[:current_forum], conn.assigns[:visible_forums], id)
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
      |> Threads.apply_user_infos(conn.assigns[:current_user], omit: [:open_close, :subscriptions, :interesting])
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    render(conn, "show.atom", thread: thread)
  end

  def show_rss(conn, %{"id" => id}) do
    thread =
      Threads.get_thread!(conn.assigns[:current_forum], conn.assigns[:visible_forums], id)
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
      |> Threads.apply_user_infos(conn.assigns[:current_user], omit: [:open_close, :subscriptions, :interesting])
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    render(conn, "show.rss", thread: thread)
  end

  def new(conn, _params) do
    changeset =
      Messages.new_message_changeset(
        nil,
        conn.assigns[:current_user],
        conn.assigns[:visible_forums],
        author: author_from_conn(conn),
        email: email_from_conn(conn),
        homepage: homepage_from_conn(conn),
        greeting: uconf(conn, "greeting"),
        farewell: uconf(conn, "farewell"),
        signature: uconf(conn, "signature"),
        std_replacement: gettext("all")
      )

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"message" => message_params, "preview" => _}) do
    {thread, message, changeset} =
      Threads.preview_thread(
        message_params,
        conn.assigns[:current_user],
        conn.assigns[:current_forum],
        conn.assigns[:visible_forums]
      )

    render(conn, "new.html", thread: thread, message: message, changeset: changeset, preview: true)
  end

  def create(conn, %{"message" => message_params}) do
    create_val =
      Threads.create_thread(
        message_params,
        conn.assigns[:current_user],
        conn.assigns[:current_forum],
        conn.assigns[:visible_forums],
        create_tags: may?(conn, "tag", :new),
        autosubscribe: Messages.autosubscribe?(conn.assigns.current_user, uconf(conn, "autosubscribe_on_post"))
      )

    case create_val do
      {:ok, thread, message} ->
        conn
        |> put_flash(:info, gettext("Thread created successfully."))
        |> redirect(to: Path.message_path(conn, :show, thread, message))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp maybe_set_cookie(conn, true, ordering),
    do: Plug.Conn.put_resp_cookie(conn, "cf_order", ordering, max_age: 360 * 24 * 60 * 60)

  defp maybe_set_cookie(conn, _, _), do: conn

  defp get_ordering(conn, user) do
    cond do
      present?(conn.params["order"]) ->
        order = conn.params["order"] |> Threads.validated_ordering(conn.assigns[:current_forum])
        {user == nil, order}

      present?(conn.cookies["cf_order"]) && user == nil ->
        order = conn.cookies["order"] |> Threads.validated_ordering(conn.assigns[:current_forum])
        {false, order}

      true ->
        {false, uconf(conn, "sort_threads")}
    end
  end

  # "srt" as in „show read threads“
  defp hide_read_threads?(conn), do: uconf(conn, "hide_read_threads") == "yes" && conn.params["srt"] != "yes"

  def load_resource(conn) do
    if action_name(conn) == :show do
      thread =
        Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, Threads.slug_from_params(conn.params))
        |> Threads.reject_deleted_threads(conn.assigns[:view_all])
        |> Threads.apply_user_infos(conn.assigns[:current_user])
        |> Threads.apply_highlights(conn)
        |> Threads.build_message_tree(uconf(conn, "sort_messages"))

      message = Messages.get_message_from_mid!(thread, conn.params["message_id"])

      conn
      |> assign(:thread, thread)
      |> assign(:message, message)
    else
      conn
    end
  end

  def allowed?(conn, :show, nil), do: allowed?(conn, :show, {conn.assigns.thread, conn.assigns.message})

  def allowed?(conn, :show, {thread, message}) do
    conn
    |> assign(:current_forum, thread.forum)
    |> CforumWeb.MessageController.allowed?(:show, {thread, message})
  end

  def allowed?(conn, _, _), do: access_forum?(conn)
end
