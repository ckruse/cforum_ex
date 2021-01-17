defmodule CforumWeb.BlogpostController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.ConfigManager
  alias Cforum.Threads.ThreadHelpers
  alias Cforum.Messages
  alias Cforum.Messages.MessageHelpers
  alias Cforum.Abilities
  alias Cforum.Subscriptions

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def show(conn, %{"month" => mon}) do
    if Regex.match?(~r/^\d+$/, mon),
      do: redirect(conn, to: Path.blog_thread_path(conn, :show, conn.assigns.article)),
      else: render(conn, "show.html")
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
        |> put_flash(:info, gettext("Article created successfully."))
        |> MessageHelpers.maybe_set_cookies(message, uuid)
        |> redirect(to: Path.blog_thread_path(conn, :show, thread))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def load_thread_and_message(conn, :show) do
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

  def allowed?(conn, action, _) when action in [:new, :create],
    do: Abilities.forum_active?(conn) && Abilities.access_forum?(conn, :write)

  def allowed?(_, _, _), do: true
end
