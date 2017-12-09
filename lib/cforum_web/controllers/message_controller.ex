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
      Messages.changeset_from_parent(
        message,
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

  def create(conn, _params) do
    conn
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

  defp author_from_conn(%{assigns: %{current_user: user}}) when not is_nil(user), do: user.username
  defp author_from_conn(conn), do: conn.cookies["cforum_author"]
  defp email_from_conn(%{assigns: %{current_user: user}} = conn) when not is_nil(user), do: uconf(conn, "email")
  defp email_from_conn(conn), do: conn.cookies["cforum_email"]
  defp homepage_from_conn(%{assigns: %{current_user: user}} = conn) when not is_nil(user), do: uconf(conn, "url")
  defp homepage_from_conn(conn), do: conn.cookies["cforum_homepage"]
end
