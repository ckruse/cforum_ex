defmodule CforumWeb.MessageController do
  use CforumWeb, :controller

  alias Cforum.Forums.Messages

  def show(conn, %{"year" => year, "month" => mon, "day" => day, "slug" => slug, "mid" => mid} = params) do
    thread_slug = "/#{year}/#{mon}/#{day}/#{slug}"

    {thread, message} =
      Messages.get_message_from_slug_and_mid!(
        conn.assigns[:current_forum],
        conn.assigns[:current_user],
        thread_slug,
        mid,
        message_order: uconf(conn, "sort_messages")
      )

    # parameter overwrites cookie overwrites config; validation
    # overwrites everything

    read_mode =
      cond do
        !blank?(params["rm"]) ->
          params["rm"]

        !blank?(conn.cookies["cf_readmode"]) && blank?(conn.assigns[:current_user]) ->
          conn.cookies["cf_readmode"]

        true ->
          uconf(conn, "standard_view")
      end

    read_mode =
      if Enum.member?(~w[thread nested], read_mode),
        do: read_mode,
        else: "thread"

    if blank?(params["rm"]) && blank?(conn.assigns[:current_user]) do
      put_resp_cookie(conn, "cf_readmode", read_mode, max_age: 360 * 24 * 60 * 60)
    else
      conn
    end
    |> render("show-#{read_mode}.html", thread: thread, message: message, read_mode: read_mode)
  end

  def new(conn, _params) do
  end

  def create(conn, _params) do
  end

  def edit(conn, _params) do
  end

  def update(conn, _params) do
  end

  def delete(conn, _params) do
  end
end
