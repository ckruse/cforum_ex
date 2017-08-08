defmodule CforumWeb.Plug.LoadUserInfoData do
  alias Cforum.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      nil ->
        conn
      user ->
        conn
        |> Plug.Conn.assign(
          :unread_notifications,
          Accounts.Notifications.count_notifications(user, true)
        )
        |> Plug.Conn.assign(
          :unread_mails,
          Accounts.PrivMessages.count_priv_messages(user, true)
        )
    end
  end
end
