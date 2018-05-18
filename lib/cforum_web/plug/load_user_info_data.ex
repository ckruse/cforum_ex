defmodule CforumWeb.Plug.LoadUserInfoData do
  @moduledoc """
  This plug is plugged in the browser pipeline and loads some meta information
  for signed in users (e.g. the count of unread PMs and notifications)
  """

  alias Cforum.Accounts
  alias Cforum.Forums.Messages

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      nil ->
        conn

      user ->
        {num_threads, num_messages} = Messages.count_unread_messages(user)

        conn
        |> Plug.Conn.assign(:unread_notifications, Accounts.Notifications.count_notifications(user, true))
        |> Plug.Conn.assign(:unread_mails, Accounts.PrivMessages.count_priv_messages(user, true))
        |> Plug.Conn.assign(:unread_threads, num_threads)
        |> Plug.Conn.assign(:unread_messages, num_messages)
    end
  end
end
