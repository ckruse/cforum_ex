defmodule CforumWeb.Messages.InterestingController do
  use CforumWeb, :controller

  plug(CforumWeb.Plug.AuthorizeAccess)

  alias Cforum.Forums.{Threads, Messages}
  alias CforumWeb.Views.Helpers.ReturnUrl

  def index(_conn, _params) do
  end

  def interesting(conn, params) do
    {thread, message} =
      Messages.get_message_from_slug_and_mid!(
        conn.assigns[:current_forum],
        conn.assigns[:current_user],
        Threads.slug_from_params(params),
        params["mid"],
        message_order: uconf(conn, "sort_messages")
      )

    Messages.mark_message_interesting(conn.assigns[:current_user], message)

    conn
    |> put_flash(:info, gettext("Message was successfully marked as interesting."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end

  def boring(conn, params) do
    {thread, message} =
      Messages.get_message_from_slug_and_mid!(
        conn.assigns[:current_forum],
        conn.assigns[:current_user],
        Threads.slug_from_params(params),
        params["mid"],
        message_order: uconf(conn, "sort_messages")
      )

    Messages.mark_message_boring(conn.assigns[:current_user], message)

    conn
    |> put_flash(:info, gettext("Interesting mark was successfully removed."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end
end
