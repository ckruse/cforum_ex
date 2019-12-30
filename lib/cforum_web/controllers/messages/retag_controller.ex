defmodule CforumWeb.Messages.RetagController do
  use CforumWeb, :controller
  use Cforum.Constants

  alias Cforum.Threads
  alias Cforum.Threads.ThreadHelpers
  alias Cforum.Messages
  alias Cforum.Messages.MessageHelpers

  alias Cforum.Abilities
  alias Cforum.ConfigManager

  def edit(conn, _params) do
    changeset = Messages.change_message(conn.assigns.message, conn.assigns[:current_user], conn.assigns.visible_forums)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, params) do
    curr_user = conn.assigns[:current_user]
    message = conn.assigns.message
    message_params = params["message"] || %{"tags" => []}

    opts = [
      create_tags: Abilities.may?(conn, "tag", :new)
    ]

    case Messages.retag_message(message, message_params, curr_user, opts) do
      {:ok, message} ->
        conn
        |> put_flash(:info, gettext("Message has successfully been retagged."))
        |> redirect(to: Path.message_path(conn, :show, conn.assigns.thread, message))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def load_resource(conn) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, ThreadHelpers.slug_from_params(conn.params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
      |> Threads.apply_user_infos(conn.assigns[:current_user], omit: [:open_close])
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["mid"])

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(conn, action, nil), do: allowed?(conn, action, {conn.assigns.thread, conn.assigns.message})
  def allowed?(conn, _action, {%{archived: true}, _message}), do: Abilities.admin?(conn)

  def allowed?(conn, _action, {thread, message}) do
    Abilities.access_forum?(conn, :moderate) || Abilities.may?(conn, "message", :edit, {thread, message}) ||
      (Abilities.badge?(conn, @badge_retag) && MessageHelpers.open?(message))
  end
end
