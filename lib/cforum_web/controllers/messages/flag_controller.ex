defmodule CforumWeb.Messages.FlagController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Threads, Messages}
  alias Cforum.Forums.{ModerationQueue, ModerationQueueEntry}

  def new(conn, _params) do
    changeset = ModerationQueue.change_create_entry(%ModerationQueueEntry{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"moderation_queue_entry" => entry_params}) do
    case ModerationQueue.create_or_update_entry(conn.assigns.message, entry_params) do
      {:ok, _entry} ->
        conn
        |> put_flash(:info, gettext("Message has successfully been flagged."))
        |> redirect(to: message_path(conn, :show, conn.assigns.thread, conn.assigns.message))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def load_resource(conn) do
    {thread, message} =
      Messages.get_message_from_slug_and_mid!(
        conn.assigns[:current_forum],
        conn.assigns[:current_user],
        Threads.slug_from_params(conn.params),
        conn.params["mid"],
        message_order: uconf(conn, "sort_messages")
      )

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(_conn, _, _), do: true
end
