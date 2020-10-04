defmodule CforumWeb.Messages.VersionController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.Threads.ThreadHelpers

  alias Cforum.Messages
  alias Cforum.Messages.MessageVersions

  alias Cforum.Abilities
  alias Cforum.ConfigManager

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def delete(conn, _params) do
    {:ok, _version} = MessageVersions.delete_message_version(conn.assigns.current_user, conn.assigns.version)

    conn
    |> put_flash(:info, gettext("Message version deleted successfully."))
    |> redirect(to: Path.message_version_path(conn, :index, conn.assigns[:thread], conn.assigns[:message]))
  end

  def load_resource(conn) do
    if !Regex.match?(~r/^\d+$/, conn.params["mid"]) || (conn.params["id"] && !Regex.match?(~r/^\d+$/, conn.params["id"])),
      do: raise(Cforum.Errors.NotFoundError, conn: conn)

    thread =
      conn.assigns[:current_forum]
      |> Threads.get_thread_by_slug!(nil, ThreadHelpers.slug_from_params(conn.params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
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

  def allowed?(conn, action, nil),
    do: allowed?(conn, action, {conn.assigns.thread, conn.assigns.message})

  def allowed?(conn, _, {_thread, message}),
    do: Abilities.access_forum?(conn) && (!message.deleted || conn.assigns.view_all)
end
