defmodule CforumWeb.Blog.ArticleController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.ConfigManager
  alias Cforum.Threads.ThreadHelpers
  alias Cforum.Threads.Thread
  alias Cforum.Messages
  alias Cforum.Messages.MessageHelpers
  alias Cforum.Abilities
  alias Cforum.Subscriptions

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def show(conn, %{"month" => mon}) do
    if Regex.match?(~r/^\d+$/, mon) do
      redirect(conn, to: Path.blog_thread_path(conn, :show, conn.assigns.article))
    else
      threads = threads_list(conn)
      next = next_article(conn.assigns.article, threads)
      prev = prev_article(conn.assigns.article, threads)
      render(conn, "show.html", prev_article: prev, next_article: next)
    end
  end

  def new(conn, _) do
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
    uuid = MessageHelpers.uuid(conn)

    opts = [
      create_tags: Abilities.may?(conn, "tag", :new),
      autosubscribe:
        Subscriptions.autosubscribe?(conn.assigns.current_user, ConfigManager.uconf(conn, "autosubscribe_on_post")),
      uuid: uuid,
      author: ViewHelpers.author_from_conn(conn),
      format: "markdown-blog"
    ]

    Threads.create_thread(
      message_params,
      conn.assigns[:current_user],
      conn.assigns[:current_forum],
      conn.assigns[:visible_forums],
      opts
    )
    |> case do
      {:ok, thread, message} ->
        conn
        |> put_flash(:info, gettext("Article created successfully."))
        |> MessageHelpers.maybe_set_cookies(message, uuid)
        |> redirect(to: Path.blog_thread_path(conn, :show, thread))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    changeset =
      Messages.change_message(conn.assigns.article.message, conn.assigns[:current_user], conn.assigns.visible_forums)

    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"message" => message_params, "preview" => _}) do
    {message, changeset} =
      Messages.preview_message(
        message_params,
        conn.assigns[:current_user],
        conn.assigns[:visible_forums],
        conn.assigns.article,
        nil,
        conn.assigns.article.message
      )

    render(conn, "edit.html", message: message, changeset: changeset, preview: true)
  end

  def update(conn, %{"message" => message_params} = params) do
    cu = conn.assigns[:current_user]
    vis_forums = conn.assigns.visible_forums
    thread = conn.assigns.article
    message = conn.assigns.article.message

    opts = [
      create_tags: Abilities.may?(conn, "tag", :new),
      remove_previous_versions: Abilities.admin?(conn) && Map.has_key?(params, "delete_previous_versions"),
      format: "markdown-blog"
    ]

    case Messages.update_message(message, message_params, cu, vis_forums, opts) do
      {:ok, _message} ->
        conn
        |> put_flash(:info, gettext("Message created successfully."))
        |> redirect(to: Path.blog_thread_path(conn, :show, thread))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def load_thread_and_message(conn, action) when action in [:show, :edit, :update] do
    thread =
      conn.assigns[:current_forum]
      |> Threads.get_thread_by_slug!(conn.assigns[:visible_forums], ThreadHelpers.slug_from_params(conn.params, true))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
      |> Threads.apply_user_infos(conn.assigns[:current_user])
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    assign(conn, :article, thread)
  end

  def load_thread_and_message(conn, _), do: conn

  def load_resource(conn) do
    load_thread_and_message(conn, action_name(conn))
  end

  def allowed?(conn, :show, _),
    do: Abilities.access_forum?(conn)

  def allowed?(conn, action, _) when action in [:new, :create],
    do: Abilities.forum_active?(conn) && Abilities.access_forum?(conn, :write)

  def allowed?(conn, action, nil) when action in [:edit, :update],
    do: allowed?(conn, action, {conn.assigns.article, conn.assigns.article.message})

  def allowed?(conn, action, {%Thread{archived: true}, msg}) when action in [:edit, :update],
    do: Abilities.admin?(conn) || Abilities.owner?(msg, conn.assigns[:current_user])

  def allowed?(conn, action, {_thread, msg}) when action in [:edit, :update] do
    if Abilities.forum_active?(conn),
      do: Abilities.access_forum?(conn, :moderate) || Abilities.owner?(msg, conn.assigns[:current_user]),
      else: Abilities.admin?(conn)
  end

  def allowed?(_, _, _), do: false

  defp threads_list(conn) do
    conn.assigns[:current_forum]
    |> Threads.list_threads(conn.assigns[:visible_forums])
    |> Threads.reject_deleted_threads(conn.assigns[:view_all])
    |> Threads.reject_invisible_threads(conn.assigns[:current_user], conn.assigns[:view_all])
    |> Threads.apply_user_infos(conn.assigns[:current_user])
    |> Threads.apply_highlights(conn)
    |> Threads.sort_threads("descending")
    |> Threads.build_message_trees(ConfigManager.uconf(conn, "sort_messages"))
  end

  defp next_article(%{archived: true}, _),
    do: nil

  defp next_article(article, threads) do
    idx = Enum.find_index(threads, &(&1.thread_id == article.thread_id))

    if !is_nil(idx) && idx > 0,
      do: Enum.at(threads, idx - 1),
      else: nil
  end

  def prev_article(%{archived: true}, _),
    do: nil

  def prev_article(article, threads) do
    idx = Enum.find_index(threads, &(&1.thread_id == article.thread_id))

    if is_nil(idx),
      do: nil,
      else: Enum.at(threads, idx + 1)
  end
end
