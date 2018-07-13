defmodule CforumWeb.Plug.ShortcutPlug do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads and assigns the current
  forum; if the forum could not be found it throws an 404 error
  """

  alias Cforum.Forums.{Threads, Messages}
  alias CforumWeb.Views.Helpers.Path

  def init(opts), do: opts

  def call(conn, _opts) do
    case Regex.named_captures(~r{^/m(?<mid>\d+)}, conn.request_path) do
      %{"mid" => id} ->
        message = Messages.get_message!(id)

        thread =
          Threads.get_thread!(
            conn.assigns.current_forum,
            conn.assigns.visible_forums,
            conn.assigns.current_user,
            message.thread_id
          )

        conn
        |> Phoenix.Controller.redirect(to: Path.message_path(conn, :show, thread, message))
        |> Plug.Conn.halt()

      _ ->
        conn
    end
  end
end
