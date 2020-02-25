defmodule Cforum.Jobs.SendInactivityNotificationMailJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  import Ecto.Query, warn: false
  require Logger

  alias Cforum.Repo
  alias Cforum.Users.User
  alias Cforum.Messages.Message

  @limits [
    {4, 100},
    {3, 75},
    {2, 50},
    {1, 25}
  ]

  @impl Oban.Worker
  def perform(_, _) do
    notify_users_inactive_longer_5years()
    Enum.each(@limits, &notify_users_inactive_in_limit/1)
  end

  defp notify_users_inactive_in_limit({years, no_messages}) do
    from(user in User,
      left_join: message in Message,
      on: message.user_id == user.user_id,
      on: fragment("?::date >= (NOW() - INTERVAL '5 years')::date", message.created_at),
      on: message.deleted == false,
      where:
        fragment("?::date < (NOW() - INTERVAL '1 year' * ?)::date", user.last_visit, ^years) or
          (is_nil(user.last_visit) and
             fragment("?::date < (NOW() - INTERVAL '1 year' * ?)::date", user.created_at, ^years)),
      group_by: user.user_id,
      having: count() < ^no_messages
    )
    |> send_notification_mails(years)

    :ok
  end

  defp notify_users_inactive_longer_5years do
    from(user in User,
      where:
        fragment("?::date <= NOW()::date - INTERVAL '5 years'", user.last_visit) or
          (is_nil(user.last_visit) and fragment("?::date <= NOW()::date - INTERVAL '5 years'", user.created_at))
    )
    |> send_notification_mails(5)
  end

  defp send_notification_mails(q, years) do
    from(user in q,
      where: is_nil(user.inactivity_notification_sent_at),
      where: fragment("EXTRACT(DAY FROM ?) = EXTRACT(DAY FROM NOW())", user.created_at),
      where: fragment("EXTRACT(MONTH FROM ?) = EXTRACT(MONTH FROM NOW())", user.created_at),
      where: not is_nil(user.email),
      where: user.email != ""
    )
    |> Repo.all()
    |> Enum.each(&notify_user(&1, years))
  end

  defp notify_user(user, years) do
    user
    |> CforumWeb.UserMailer.inactivity_mail(years)
    |> Cforum.Mailer.deliver!()

    from(user in User, where: user.user_id == ^user.user_id)
    |> Repo.update_all(set: [inactivity_notification_sent_at: Timex.now()])
  end
end
