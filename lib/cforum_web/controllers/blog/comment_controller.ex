defmodule CforumWeb.Blog.CommentController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.Messages
  alias Cforum.Messages.MessageHelpers
  alias Cforum.ConfigManager
  alias Cforum.Subscriptions

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.MessageController
  alias CforumWeb.Blog.ArticleController

  def new(conn, params) do
    changeset =
      Messages.new_message_changeset(
        conn.assigns.parent,
        conn.assigns[:current_user],
        conn.assigns[:visible_forums],
        Map.get(conn.params, "message", %{}),
        strip_signature: ConfigManager.uconf(conn, "quote_signature") != "yes",
        author: ViewHelpers.author_from_conn(conn),
        email: ViewHelpers.email_from_conn(conn),
        homepage: ViewHelpers.homepage_from_conn(conn),
        greeting: ConfigManager.uconf(conn, "greeting"),
        farewell: ConfigManager.uconf(conn, "farewell"),
        signature: ConfigManager.uconf(conn, "signature"),
        quote: MessageController.quote?(conn, params),
        std_replacement: gettext("all")
      )

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"message" => message_params, "preview" => _}) do
    {message, changeset} =
      Messages.preview_message(
        message_params,
        conn.assigns[:current_user],
        conn.assigns[:visible_forums],
        conn.assigns.article,
        conn.assigns.parent
      )

    render(conn, "new.html", message: message, changeset: changeset, preview: true)
  end

  def create(conn, %{"message" => message_params}) do
    cu = conn.assigns[:current_user]
    vis_forums = conn.assigns.visible_forums
    parent = conn.assigns.parent
    thread = conn.assigns.article
    uuid = MessageHelpers.uuid(conn)

    opts = [
      uuid: uuid,
      author: ViewHelpers.author_from_conn(conn),
      create_tags: Abilities.may?(conn, "tag", :new),
      autosubscribe: Subscriptions.autosubscribe?(cu, ConfigManager.uconf(conn, "autosubscribe_on_post"))
    ]

    case Messages.create_message(message_params, cu, vis_forums, thread, parent, opts) do
      {:ok, message} ->
        conn
        |> put_flash(:info, gettext("Message created successfully."))
        |> MessageHelpers.maybe_set_cookies(message, uuid)
        |> redirect(to: Path.blog_comment_path(conn, :show, thread, message))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def load_resource(conn) do
    conn = ArticleController.load_thread_and_message(conn, :show)
    message = Messages.get_message_from_mid!(conn.assigns[:article], conn.params["mid"])

    assign(conn, :parent, message)
  end

  def allowed?(conn, action, nil) when action in [:new, :create],
    do: allowed?(conn, action, {conn.assigns.article, conn.assigns.parent})

  def allowed?(conn, action, {thread, message}) when action in [:new, :create] do
    Abilities.forum_active?(conn) && Abilities.access_forum?(conn, :answer) && MessageHelpers.open?(message) &&
      !thread.archived
  end

  def allowed(conn, _, _), do: Abilities.forum_active?(conn) && Abilities.access_forum?(conn, :read)
end
