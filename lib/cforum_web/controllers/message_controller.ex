defmodule CforumWeb.MessageController do
  use CforumWeb, :controller

  alias Cforum.Forums.Messages
  alias Cforum.Forums.{Thread, Threads}

  def show(conn, params) do
    # parameter overwrites cookie overwrites config; validation
    # overwrites everything

    read_mode =
      conn
      |> parse_readmode(params)
      |> validate_readmode

    if signed_in?(conn) do
      Cforum.Helpers.AsyncHelper.run_async(fn ->
        mark_messages_read(read_mode, conn.assigns[:current_user], conn.assigns.thread, conn.assigns.message)

        if uconf(conn, "delete_read_notifications_on_abonements") == "yes",
          do: Messages.unnotify_user(conn.assigns.current_user, read_mode, conn.assigns.thread, conn.assigns.message)
      end)
    end

    conn
    |> maybe_put_readmode(params, read_mode)
    |> render("show-#{read_mode}.html", read_mode: read_mode)
  end

  def new(conn, params) do
    changeset =
      Messages.new_message_changeset(
        conn.assigns.parent,
        conn.assigns[:current_user],
        conn.assigns[:visible_forums],
        strip_signature: uconf(conn, "quote_signature") != "yes",
        author: author_from_conn(conn),
        email: email_from_conn(conn),
        homepage: homepage_from_conn(conn),
        greeting: uconf(conn, "greeting"),
        farewell: uconf(conn, "farewell"),
        signature: uconf(conn, "signature"),
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

    opts = [
      create_tags: may?(conn, "tag", :new),
      autosubscribe: Messages.autosubscribe?(cu, uconf(conn, "autosubscribe_on_post"))
    ]

    case Messages.create_message(message_params, cu, vis_forums, thread, parent, opts) do
      {:ok, message} ->
        conn
        |> put_flash(:info, gettext("Message created successfully."))
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
      create_tags: may?(conn, "tag", :new),
      remove_previous_versions: admin?(conn) && Map.has_key?(params, "delete_previous_versions")
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

  def delete(conn, _params) do
    conn
  end

  #
  # private helpers
  #

  defp get_message(conn, %{"mid" => mid} = params) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, Threads.slug_from_params(params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.apply_user_infos(conn.assigns[:current_user], omit: [:open_close])
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, mid)

    {thread, message}
  end

  defp quote?(conn, params) do
    if blank?(params["with_quote"]),
      do: uconf(conn, "quote_by_default") == "yes",
      else: params["with_quote"] == "yes"
  end

  defp parse_readmode(conn, params) do
    cond do
      present?(params["rm"]) ->
        params["rm"]

      present?(conn.cookies["cf_readmode"]) && blank?(conn.assigns[:current_user]) ->
        conn.cookies["cf_readmode"]

      true ->
        uconf(conn, "standard_view")
    end
  end

  defp validate_readmode("nested"), do: "nested"
  defp validate_readmode("nested-view"), do: "nested"
  defp validate_readmode(_), do: "thread"

  defp maybe_put_readmode(conn, params, read_mode) do
    if present?(params["rm"]) && blank?(conn.assigns[:current_user]),
      do: put_resp_cookie(conn, "cf_readmode", read_mode, max_age: 360 * 24 * 60 * 60),
      else: conn
  end

  defp mark_messages_read(_, _, %Thread{archived: true}, _), do: nil
  defp mark_messages_read("nested", user, thread, _), do: Messages.mark_messages_read(user, thread.messages)
  defp mark_messages_read(_, user, _, message), do: Messages.mark_messages_read(user, message)

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

  # TODO implement proper rights
  def allowed?(conn, action, nil) when action in [:new, :create],
    do: allowed?(conn, action, {conn.assigns.thread, conn.assigns.parent})

  def allowed?(conn, action, {_thread, message}) when action in [:new, :create],
    do: access_forum?(conn, :write) && !message.deleted

  def allowed?(conn, action, nil) when action in [:edit, :update],
    do: allowed?(conn, action, {conn.assigns.thread, conn.assigns.message})

  def allowed?(conn, action, {thread, msg}) when action in [:edit, :update] do
    access_forum?(conn, :moderate) ||
      (Messages.editable_age?(msg, minutes: conf(conn, "max_editable_age", :int)) && !Messages.answer?(thread, msg) &&
         Messages.owner?(conn, msg))
  end

  def allowed?(conn, :show, nil),
    do: allowed?(conn, :show, {conn.assigns.thread, conn.assigns.message})

  def allowed?(conn, :show, {_thread, message}),
    do: access_forum?(conn) && (!message.deleted || conn.assigns.view_all)

  def allowed?(_conn, val1, val2), do: raise(inspect([val1, val2]))
  # def allowed?(conn, _, _), do: access_forum?(conn)
end
