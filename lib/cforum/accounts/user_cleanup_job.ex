defmodule Cforum.Accounts.UserCleanupJob do
  import Ecto.{Query, Changeset}, warn: false
  require Logger

  alias Cforum.Repo
  alias Cforum.System
  alias Cforum.Accounts.User

  def cleanup do
    cleanup_unconfirmed_users()
    cleanup_users_wo_posts()
    Cachex.clear(:cforum)
  end

  def cleanup_unconfirmed_users() do
    from(user in User,
      where: is_nil(user.confirmed_at),
      where: fragment("? + interval '24 hours'", user.confirmation_sent_at) <= ^DateTime.utc_now()
    )
    |> delete_users()
  end

  def cleanup_users_wo_posts() do
    from(user in User,
      where:
        (is_nil(user.last_visit) and fragment("? + interval '30 days' <= NOW()", user.created_at)) or
          fragment("? + interval '30 days'", user.last_visit) <= ^DateTime.utc_now(),
      where:
        fragment(
          "NOT EXISTS(SELECT message_id FROM messages WHERE messages.user_id = ? and messages.deleted = false)",
          user.user_id
        )
    )
    |> delete_users()
  end

  defp delete_users(query) do
    query
    |> Repo.all()
    |> Enum.each(fn user ->
      Logger.info("Automatically deleting user #{user.username}")
      System.audited("autodestroy", nil, fn -> Repo.delete(user) end)
    end)
  end
end
