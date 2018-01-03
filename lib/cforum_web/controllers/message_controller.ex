defmodule CforumWeb.MessageController do
  use CforumWeb, :controller

  alias Cforum.Forums.Messages
  alias Cforum.Forums.Threads

  def show(conn, params) do
    {thread, message} = get_message(conn, params)

    # parameter overwrites cookie overwrites config; validation
    # overwrites everything

    read_mode =
      conn
      |> parse_readmode(params)
      |> validate_readmode

    conn
    |> maybe_put_readmode(params, read_mode)
    |> render("show-#{read_mode}.html", thread: thread, message: message, read_mode: read_mode)
  end

  def new(conn, params) do
    {thread, message} = get_message(conn, params)

    changeset =
      Messages.new_message_changeset(
        message,
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

    render(conn, "new.html", thread: thread, parent: message, changeset: changeset)
  end

  def create(conn, %{"message" => message_params} = params) do
    {thread, parent} = get_message(conn, params)

    if Map.has_key?(params, "preview"),
      do: show_preview(conn, message_params, thread, parent),
      else: create_message(conn, message_params, thread, parent)
  end

  defp show_preview(conn, params, thread, parent) do
    {message, changeset} = Messages.preview_message(params, conn.assigns[:current_user], thread, parent)
    render(conn, "new.html", thread: thread, parent: parent, message: message, changeset: changeset, preview: true)
  end

  defp create_message(conn, params, thread, parent) do
    case Messages.create_message(params, conn.assigns[:current_user], conn.assigns[:visible_forums], thread, parent) do
      {:ok, message} ->
        conn
        |> put_flash(:info, gettext("Message created successfully."))
        |> redirect(to: message_path(conn, :show, thread, message))

      {:error, changeset} ->
        render(conn, "new.html", thread: thread, parent: parent, changeset: changeset)
    end
  end

  def edit(conn, _params) do
    conn
  end

  def update(conn, _params) do
    conn
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
      message_order: uconf(conn, "sort_messages")
    )
  end

  defp quote?(conn, params) do
    if blank?(params["with_quote"]) do
      uconf(conn, "quote_by_default") == "yes"
    else
      params["with_quote"] == "yes"
    end
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
end
