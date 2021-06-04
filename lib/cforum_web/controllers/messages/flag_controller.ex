defmodule CforumWeb.Messages.FlagController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.Threads.ThreadHelpers

  alias Cforum.Messages

  alias Cforum.ModerationQueue
  alias Cforum.ModerationQueue.ModerationQueueEntry

  alias Cforum.ConfigManager

  def new(conn, _params) do
    changeset = ModerationQueue.change_create_entry(%ModerationQueueEntry{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"moderation_queue_entry" => entry_params}) do
    case ModerationQueue.create_or_update_entry(conn.assigns.message, entry_params) do
      {:ok, _entry} ->
        conn
        |> put_flash(:info, gettext("Message has successfully been flagged."))
        |> redirect(to: Path.message_path(conn, :show, conn.assigns.thread, conn.assigns.message))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def load_resource(conn) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, ThreadHelpers.slug_from_params(conn.params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["mid"])

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(_conn, _, {thread, _message}), do: not thread.archived
  def allowed?(conn, action, _), do: allowed?(conn, action, {conn.assigns.thread, conn.assigns.message})

  def id_fields(_), do: ["mid"]
end
