defmodule CforumWeb.MessageController do
  use CforumWeb, :controller

  alias Cforum.Forums.Messages
  alias Cforum.Forums.Threads

  def show(conn, params) do
    # parameter overwrites cookie overwrites config; validation
    # overwrites everything

    read_mode =
      conn
      |> parse_readmode(params)
      |> validate_readmode

    if read_mode == "nested",
      do: Messages.mark_messages_read(conn.assigns[:current_user], conn.assigns.thread.messages),
      else: Messages.mark_messages_read(conn.assigns[:current_user], conn.assigns.message)

    if uconf(conn, "delete_read_notifications_on_abonements") == "yes",
      do: Messages.unnotify_user(conn.assigns.current_user, conn.assigns.message)

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

  def create(conn, %{"message" => message_params} = params) do
    if Map.has_key?(params, "preview"),
      do: show_preview(conn, message_params, conn.assigns.thread),
      else: create_message(conn, message_params, conn.assigns.thread)
  end

  defp show_preview(conn, params, thread) do
    {message, changeset} = Messages.preview_message(params, conn.assigns[:current_user], thread, conn.assigns.parent)
    render(conn, "new.html", message: message, changeset: changeset, preview: true)
  end

  defp create_message(conn, params, thread) do
    cu = conn.assigns[:current_user]
    vis_forums = conn.assigns.visible_forums
    parent = conn.assigns.parent

    opts = [
      create_tags: may?(conn, "tag", :new),
      autosubscribe: Messages.autosubscribe?(cu, uconf(conn, "autosubscribe_on_post"))
    ]

    case Messages.create_message(params, cu, vis_forums, thread, parent, opts) do
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

  def update(conn, %{"message" => message_params} = params) do
    if Map.has_key?(params, "preview") do
      {message, changeset} =
        Messages.preview_message(
          message_params,
          conn.assigns[:current_user],
          conn.assigns.thread,
          nil,
          conn.assigns.message
        )

      render(conn, "edit.html", message: message, changeset: changeset, preview: true)
    else
      conn
    end
  end

  def delete(conn, _params) do
    conn
  end

  #
  # private helpers
  #

  defp get_message(conn, %{"mid" => mid} = params) do
    Messages.get_message_from_slug_and_mid!(
      conn.assigns[:current_forum],
      conn.assigns[:current_user],
      Threads.slug_from_params(params),
      mid,
      message_order: uconf(conn, "sort_messages"),
      view_all: conn.assigns.view_all,
      leave_out_invisible: !conn.assigns.view_all
    )
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
