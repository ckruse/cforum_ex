defmodule Cforum.Jobs.UserCleanupJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  import Ecto.Query, warn: false
  require Logger

  alias Cforum.Repo
  alias Cforum.System
  alias Cforum.Users.User

  @impl Oban.Worker
  def perform(_, _) do
    cleanup_unconfirmed_users()
    cleanup_users_wo_posts()
    cleanup_inactive_users()

    Cachex.clear(:cforum)
  end

  defp cleanup_inactive_users() do
    from(user in User, where: fragment("? < NOW() - INTERVAL '30 days'", user.inactivity_notification_sent_at))
    |> Repo.all()
    |> delete_users()
  end

  defp cleanup_unconfirmed_users() do
    from(user in User,
      where: is_nil(user.confirmed_at),
      where: fragment("? + interval '24 hours'", user.confirmation_sent_at) <= ^DateTime.utc_now()
    )
    |> delete_users()
  end

  defp cleanup_users_wo_posts() do
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
    Repo.transaction(
      fn ->
        query
        |> Repo.stream()
        |> Enum.each(fn user ->
          Logger.info("Automatically deleting user #{user.username}")
          System.audited("autodestroy", nil, fn -> Repo.delete(user) end)
        end)
      end,
      timeout: :infinity
    )
  end
end
