defmodule CforumWeb.MessageController do
  use CforumWeb, :controller
  use Cforum.Constants

  alias Cforum.Abilities
  alias Cforum.Messages
  alias Cforum.Subscriptions
  alias Cforum.Messages.MessageHelpers
  alias Cforum.ReadMessages

  alias Cforum.Threads
  alias Cforum.Threads.Thread
  alias Cforum.Threads.ThreadHelpers

  alias Cforum.ConfigManager
  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  @notification_types [
    "message:create-answer",
    "message:create-activity",
    "message:mention"
  ]

  def show(conn, params) do
    if proper_forum?(conn) do
      # parameter overwrites cookie overwrites config; validation
      # overwrites everything
      read_mode =
        conn
        |> parse_readmode(params)
        |> validate_readmode()

      if Abilities.signed_in?(conn) and !conn.assigns.thread.archived,
        do: run_async_handlers(conn, read_mode)

      conn
      |> Plug.Conn.assign(:read_mode, read_mode)
      |> maybe_put_readmode(params, read_mode)
      |> maybe_add_rm()
      |> render("show-#{read_mode}.html")
    else
      conn
      |> put_status(301)
      |> redirect(to: Path.message_path(conn, :show, conn.assigns.thread, conn.assigns.message))
    end
  end

  defp run_async_handlers(conn, read_mode) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      if ConfigManager.uconf(conn, "mark_nested_read_via_js") != "yes" || read_mode != "nested",
        do: mark_messages_read(read_mode, conn.assigns[:current_user], conn.assigns.thread, conn.assigns.message)

      if ConfigManager.uconf(conn, "delete_read_notifications") == "yes" do
        Messages.unnotify_user(
          conn.assigns.current_user,
          read_mode,
          conn.assigns.thread,
          conn.assigns.message,
          @notification_types
        )
      end
    end)
  end

  def proper_forum?(conn) do
    Helpers.present?(conn.assigns.current_forum) && conn.assigns.message.forum_id == conn.assigns.current_forum.forum_id
  end

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
        quote: quote?(conn, params),
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
        conn.assigns.thread,
        conn.assigns.parent
      )

    render(conn, "new.html", message: message, changeset: changeset, preview: true)
  end

  def create(conn, %{"message" => message_params}) do
    cu = conn.assigns[:current_user]
    vis_forums = conn.assigns.visible_forums
    parent = conn.assigns.parent
    thread = conn.assigns.thread
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
        |> redirect(to: Path.message_path(conn, :show, thread, message))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    changeset = Messages.change_message(conn.assigns.message, conn.assigns[:current_user], conn.assigns.visible_forums)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"message" => message_params, "preview" => _}) do
    {message, changeset} =
      Messages.preview_message(
        message_params,
        conn.assigns[:current_user],
        conn.assigns[:visible_forums],
        conn.assigns.thread,
        nil,
        conn.assigns.message
      )

    render(conn, "edit.html", message: message, changeset: changeset, preview: true)
  end

  def update(conn, %{"message" => message_params} = params) do
    cu = conn.assigns[:current_user]
    vis_forums = conn.assigns.visible_forums
    thread = conn.assigns.thread
    message = conn.assigns.message

    opts = [
      create_tags: Abilities.may?(conn, "tag", :new),
      remove_previous_versions: Abilities.admin?(conn) && Map.has_key?(params, "delete_previous_versions")
    ]

    case Messages.update_message(message, message_params, cu, vis_forums, opts) do
      {:ok, message} ->
        conn
        |> put_flash(:info, gettext("Message created successfully."))
        |> redirect(to: Path.message_path(conn, :show, thread, message))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  #
  # private helpers
  #

  defp get_message(conn, %{"mid" => mid} = params) do
    thread =
      conn.assigns[:current_forum]
      |> Threads.get_thread_by_slug!(conn.assigns[:visible_forums], ThreadHelpers.slug_from_params(params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
      |> Threads.apply_user_infos(conn.assigns[:current_user], omit: [:open_close], include: [:invisible])
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, mid)

    {thread, message}
  end

  def quote?(conn, params) do
    if Helpers.blank?(params["with_quote"]),
      do: ConfigManager.uconf(conn, "quote_by_default") == "yes",
      else: params["with_quote"] == "yes"
  end

  defp parse_readmode(conn, params) do
    cond do
      Helpers.present?(params["rm"]) ->
        params["rm"]

      Helpers.present?(conn.cookies["cf_readmode"]) && Helpers.blank?(conn.assigns[:current_user]) ->
        conn.cookies["cf_readmode"]

      true ->
        ConfigManager.uconf(conn, "standard_view")
    end
  end

  defp validate_readmode("nested"), do: "nested"
  defp validate_readmode("nested-view"), do: "nested"
  defp validate_readmode(_), do: "thread"

  defp valid_readmode?("thread"), do: true
  defp valid_readmode?("nested"), do: true
  defp valid_readmode?(_), do: false

  defp maybe_put_readmode(conn, params, read_mode) do
    if Helpers.present?(params["rm"]) && Helpers.blank?(conn.assigns[:current_user]),
      do: put_resp_cookie(conn, "cf_readmode", read_mode, max_age: 360 * 24 * 60 * 60),
      else: conn
  end

  defp maybe_add_rm(conn) do
    assign_rm =
      Helpers.present?(conn.params["rm"]) && Helpers.present?(conn.assigns[:current_user]) &&
        valid_readmode?(conn.params["rm"])

    if assign_rm,
      do: assign(conn, :rm, conn.params["rm"]),
      else: conn
  end

  defp mark_messages_read(_, _, %Thread{archived: true}, _), do: nil
  defp mark_messages_read("nested", user, thread, _), do: ReadMessages.mark_messages_read(user, thread.messages)
  defp mark_messages_read(_, user, _, message), do: ReadMessages.mark_messages_read(user, message)

  def load_resource(conn) do
    case action_name(conn) do
      act when act in [:show, :edit, :update] ->
        {thread, message} = get_message(conn, conn.params)

        conn
        |> assign(:thread, thread)
        |> assign(:message, message)

      act when act in [:new, :create] ->
        {thread, message} = get_message(conn, conn.params)

        conn
        |> assign(:thread, thread)
        |> assign(:parent, message)

      _ ->
        conn
    end
  end

  def allowed?(conn, action, nil) when action in [:new, :create],
    do: allowed?(conn, action, {conn.assigns.thread, conn.assigns.parent})

  def allowed?(conn, action, {thread, message}) when action in [:new, :create] do
    Abilities.forum_active?(conn) && Abilities.access_forum?(conn, :answer) && MessageHelpers.open?(message) &&
      !thread.archived
  end

  def allowed?(conn, action, nil) when action in [:edit, :update],
    do: allowed?(conn, action, {conn.assigns.thread, conn.assigns.message})

  def allowed?(conn, action, {%Thread{archived: true} = thread, msg}) when action in [:edit, :update],
    do: Abilities.admin?(conn) && (thread.forum.type != "blog" || msg.parent_id != nil)

  def allowed?(conn, action, {thread, msg}) when action in [:edit, :update] do
    editable =
      if Abilities.forum_active?(conn),
        do: Abilities.access_forum?(conn, :moderate) || edit?(conn, thread, msg),
        else: Abilities.admin?(conn)

    editable && (thread.forum.type != "blog" || msg.parent_id != nil)
  end

  def allowed?(conn, :show, nil),
    do: allowed?(conn, :show, {conn.assigns.thread, conn.assigns.message})

  def allowed?(conn, :show, {_thread, message}),
    do: Abilities.access_forum?(conn) && (!MessageHelpers.message_deleted?(message) || conn.assigns.view_all)

  def allowed?(_conn, val1, val2), do: raise(inspect([val1, val2]))
  # def allowed?(conn, _, _), do: Abilities.access_forum?(conn)

  defp edit?(conn, thread, msg) do
    MessageHelpers.open?(msg) && !MessageHelpers.answer?(thread, msg) &&
      MessageHelpers.editable_age?(msg, minutes: ConfigManager.conf(conn, "max_editable_age", :int)) &&
      (MessageHelpers.owner?(conn, msg) || edit_by_badge?(conn, msg))
  end

  defp edit_by_badge?(conn, %{parent_id: nil}),
    do: Abilities.badge?(conn, @badge_edit_question) || Abilities.badge?(conn, @badge_edit_answer)

  defp edit_by_badge?(conn, _), do: Abilities.badge?(conn, @badge_edit_answer)

  def id_fields(_), do: ["mid"]
end
