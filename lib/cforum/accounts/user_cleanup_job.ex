defmodule Cforum.Accounts.UserCleanupJob do
  use Appsignal.Instrumentation.Decorators

  alias Cforum.Accounts.{Users, User}

  import Ecto.{Query, Changeset}, warn: false
  require Logger

  alias Cforum.Repo

  @decorate transaction()
  def cleanup do
    cleanup_unconfirmed_users()
    cleanup_users_wo_posts()
  end

  @decorate transaction_event()
  def cleanup_unconfirmed_users() do
    from(user in User,
      where: is_nil(user.confirmed_at),
      where: fragment("? + interval '24 hours'", user.confirmation_sent_at) <= ^DateTime.utc_now()
    )
    |> delete_users()
  end

  @decorate transaction_event()
  def cleanup_users_wo_posts() do
    from(user in User,
      where: is_nil(user.last_visit) or fragment("? + interval '30 days'", user.last_visit) <= ^DateTime.utc_now(),
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
      Users.delete_user(nil, user)
    end)
  end
end
