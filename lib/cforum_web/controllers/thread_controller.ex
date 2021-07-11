defmodule CforumWeb.ThreadController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.Threads
  alias Cforum.Messages

  alias Cforum.Threads.ThreadHelpers
  alias Cforum.Messages.MessageHelpers
  alias Cforum.Subscriptions
  alias Cforum.ConfigManager

  alias CforumWeb.Paginator
  alias CforumWeb.Views.ViewHelpers

  def index(conn, params) do
    page = Paginator.parse_page(params["p"]) - 1
    limit = ConfigManager.uconf(conn, "pagination", :int)
    use_paging = ConfigManager.uconf(conn, "use_paging") == "yes"
    user = conn.assigns[:current_user]
    {set_order_cookie, ordering} = ThreadHelpers.get_ordering(conn, user)

    threads = thread_list(conn)
    all_threads_count = length(threads)

    threads =
      threads
      |> Threads.sort_threads(ordering)
      |> Threads.paged_thread_list(page, limit, use_paging)
      |> Threads.build_message_trees(ConfigManager.uconf(conn, "sort_messages"))

    p = Paginator.paginate(all_threads_count, per_page: limit, page: page + 1)

    conn
    |> maybe_set_cookie(set_order_cookie, ordering)
    |> render("index.html",
      threads: threads,
      all_threads_count: all_threads_count,
      page: p,
      order: ordering,
      use_paging: use_paging
    )
  end

  def index_unanswered(conn, params) do
    page = Paginator.parse_page(params["p"]) - 1
    limit = ConfigManager.uconf(conn, "pagination", :int)
    use_paging = ConfigManager.uconf(conn, "use_paging") == "yes"
    user = conn.assigns[:current_user]
    {set_order_cookie, ordering} = ThreadHelpers.get_ordering(conn, user)

    threads = thread_list(conn)
    all_threads_count = length(threads)

    threads =
      threads
      |> Threads.sort_threads(ordering)
      |> Threads.paged_thread_list(page, limit, use_paging)
      |> Threads.build_message_trees(ConfigManager.uconf(conn, "sort_messages"))

    p = Paginator.paginate(all_threads_count, per_page: limit, page: page + 1)

    conn
    |> maybe_set_cookie(set_order_cookie, ordering)
    |> render("index_unanswered.html",
      threads: threads,
      all_threads_count: all_threads_count,
      page: p,
      order: ordering,
      use_paging: use_paging
    )
  end

  def show(conn, %{"invisible" => "no"} = params) do
    if conn.assigns.thread.attribs[:invisible],
      do: html(conn, ""),
      else: show(conn, Map.drop(params, ["invisible"]))
  end

  def show(conn, params) do
    conn
    |> put_layout(false)
    |> render("thread.html",
      index: str_to_bool(params["index"], true),
      id_prefix: params["id_prefix"],
      fold: params["fold"]
    )
  end

  defp str_to_bool(nil, default), do: default
  defp str_to_bool("yes", _), do: true
  defp str_to_bool(_, _), do: false

  def index_atom(conn, _params) do
    threads = feed_thread_list(conn)
    render(conn, "index.atom", threads: threads)
  end

  def index_rss(conn, _params) do
    threads = feed_thread_list(conn)
    render(conn, "index.rss", threads: threads)
  end

  def show_atom(conn, %{"id" => id}) do
    thread = get_thread_feed(conn, id)
    render(conn, "show.atom", thread: thread)
  end

  def show_rss(conn, %{"id" => id}) do
    thread = get_thread_feed(conn, id)
    render(conn, "show.rss", thread: thread)
  end

  def new(conn, _params) do
    changeset =
      Messages.new_message_changeset(
        nil,
        conn.assigns[:current_user],
        conn.assigns[:visible_forums],
        Map.get(conn.params, "message", %{}),
        author: ViewHelpers.author_from_conn(conn),
        email: ViewHelpers.email_from_conn(conn),
        homepage: ViewHelpers.homepage_from_conn(conn),
        greeting: ConfigManager.uconf(conn, "greeting"),
        farewell: ConfigManager.uconf(conn, "farewell"),
        signature: ConfigManager.uconf(conn, "signature"),
        std_replacement: gettext("all")
      )

    render(conn, "new.html", changeset: changeset, writable_forums: writable_forums(conn))
  end

  def create(conn, %{"message" => message_params, "preview" => _}) do
    {thread, message, changeset} =
      Threads.preview_thread(
        message_params,
        conn.assigns[:current_user],
        conn.assigns[:current_forum],
        conn.assigns[:visible_forums]
      )

    render(conn, "new.html",
      thread: thread,
      message: message,
      changeset: changeset,
      preview: true,
      writable_forums: writable_forums(conn)
    )
  end

  def create(conn, %{"message" => message_params}) do
    uuid = MessageHelpers.uuid(conn)

    opts = [
      create_tags: Abilities.may?(conn, "tag", :new),
      autosubscribe:
        Subscriptions.autosubscribe?(conn.assigns.current_user, ConfigManager.uconf(conn, "autosubscribe_on_post")),
      uuid: uuid,
      author: ViewHelpers.author_from_conn(conn)
    ]

    create_val =
      Threads.create_thread(
        message_params,
        conn.assigns[:current_user],
        conn.assigns[:current_forum],
        conn.assigns[:visible_forums],
        opts
      )

    case create_val do
      {:ok, thread, message} ->
        conn
        |> put_flash(:info, gettext("Thread created successfully."))
        |> MessageHelpers.maybe_set_cookies(message, uuid)
        |> redirect(to: Path.message_path(conn, :show, thread, message))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, writable_forums: writable_forums(conn))
    end
  end

  defp maybe_set_cookie(conn, true, ordering),
    do: Plug.Conn.put_resp_cookie(conn, "cf_order", ordering, max_age: 360 * 24 * 60 * 60)

  defp maybe_set_cookie(conn, _, _), do: conn

  defp load_thread_and_message(conn, :show) do
    params = Map.update!(conn.params, "slug", &Regex.replace(~r/\.(atom|rss)$/, &1, ""))

    thread =
      conn.assigns[:current_forum]
      |> Threads.get_thread_by_slug!(conn.assigns[:visible_forums], ThreadHelpers.slug_from_params(params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
      |> Threads.apply_user_infos(conn.assigns[:current_user],
        include: [:invisible],
        close_read_threads: ConfigManager.uconf(conn, "open_close_close_when_read") == "yes",
        open_close_default_state: ConfigManager.uconf(conn, "open_close_default")
      )
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    cond do
      conn.request_path =~ ~r/\.atom$/ ->
        conn
        |> redirect(to: Path.thread_path(conn, :atom, thread))
        |> Plug.Conn.halt()

      conn.request_path =~ ~r/\.rss$/ ->
        conn
        |> redirect(to: Path.thread_path(conn, :rss, thread))
        |> Plug.Conn.halt()

      true ->
        message = Messages.get_message_from_mid!(thread, conn.params["message_id"])

        conn
        |> assign(:thread, thread)
        |> assign(:message, message)
    end
  end

  defp load_thread_and_message(conn, _), do: conn

  def load_resource(conn) do
    conn
    |> load_thread_and_message(action_name(conn))
    |> assign(:srt, not ThreadHelpers.hide_read_threads?(conn))
  end

  def allowed?(conn, :show, nil), do: allowed?(conn, :show, {conn.assigns.thread, conn.assigns.message})

  def allowed?(conn, :show, {thread, message}) do
    conn
    |> assign(:current_forum, thread.forum)
    |> CforumWeb.MessageController.allowed?(:show, {thread, message})
  end

  def allowed?(conn, action, _) when action in [:new, :create] do
    Abilities.forum_active?(conn) && Abilities.access_forum?(conn, :write) &&
      (conn.assigns[:current_forum] == nil || conn.assigns[:current_forum].type != "blog")
  end

  def allowed?(conn, _, _), do: Abilities.access_forum?(conn)

  defp thread_list(conn) do
    conn.assigns[:current_forum]
    |> Threads.list_threads(conn.assigns[:visible_forums])
    |> Threads.reject_deleted_threads(conn.assigns[:view_all])
    |> Threads.reject_drafts(conn.assigns[:current_user], conn.assigns[:view_all])
    |> Threads.reject_invisible_threads(conn.assigns[:current_user], conn.assigns[:view_all])
    |> Threads.apply_user_infos(conn.assigns[:current_user],
      close_read_threads: ConfigManager.uconf(conn, "open_close_close_when_read") == "yes",
      open_close_default_state: ConfigManager.uconf(conn, "open_close_default")
    )
    |> Threads.reject_read_threads(ThreadHelpers.hide_read_threads?(conn))
    |> Threads.apply_highlights(conn)
    |> Threads.filter_wo_answer(conn.params["only_wo_answer"] != nil)
  end

  defp feed_thread_list(conn) do
    user = conn.assigns[:current_user]
    {_, ordering} = ThreadHelpers.get_ordering(conn, user)

    conn.assigns[:current_forum]
    |> Threads.list_threads(conn.assigns[:visible_forums])
    |> Threads.reject_deleted_threads(conn.assigns[:view_all], true)
    |> Threads.reject_drafts(conn.assigns[:current_user], conn.assigns[:view_all])
    |> Threads.reject_invisible_threads(user, conn.assigns[:view_all])
    |> Threads.apply_user_infos(user, omit: [:open_close, :subscriptions, :interesting])
    |> Threads.reject_read_threads(ThreadHelpers.hide_read_threads?(conn))
    |> Threads.apply_highlights(conn)
    |> Threads.sort_threads(ordering)
    |> Threads.build_message_trees(ConfigManager.uconf(conn, "sort_messages"))
  end

  defp get_thread_feed(conn, id) do
    conn.assigns[:current_forum]
    |> Threads.get_thread!(conn.assigns[:visible_forums], id)
    |> Threads.reject_deleted_threads(conn.assigns[:view_all], true)
    |> Threads.ensure_found!()
    |> Threads.apply_user_infos(conn.assigns[:current_user], omit: [:open_close, :subscriptions, :interesting])
    |> Threads.apply_highlights(conn)
    |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))
  end

  defp writable_forums(conn) do
    Enum.filter(conn.assigns[:visible_forums] || [], fn forum ->
      Abilities.forum_active?(forum) && Abilities.access_forum?(conn, forum, :write) && forum.type != "blog"
    end)
  end

  def id_fields(_), do: ["id"]
end
