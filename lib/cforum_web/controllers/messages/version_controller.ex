defmodule CforumWeb.Messages.VersionController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.Threads.ThreadHelpers

  alias Cforum.Messages
  alias Cforum.Messages.MessageVersions

  alias Cforum.ConfigManager

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def delete(conn, _params) do
    {:ok, _version} = MessageVersions.delete_message_version(conn.assigns.current_user, conn.assigns.version)

    conn
    |> put_flash(:info, gettext("Message version deleted successfully."))
    |> redirect(
      to: Path.message_version_path(conn, :index, conn.assigns[:thread], conn.assigns[:message], view_all: "yes")
    )
  end

  def load_resource(conn) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, ThreadHelpers.slug_from_params(conn.params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["mid"])

    version =
      if conn.params["id"],
        do: MessageVersions.get_message_version!(message, conn.params["id"]),
        else: nil

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
    |> Plug.Conn.assign(:version, version)
  end

  def allowed?(conn, :delete, _), do: Abilities.admin?(conn)
  def allowed?(_, _, _), do: true
end
