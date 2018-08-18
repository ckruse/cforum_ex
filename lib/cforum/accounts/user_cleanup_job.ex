defmodule Cforum.Accounts.UserCleanupJob do
  alias Cforum.Accounts.{Users, User}

  import Ecto.{Query, Changeset}, warn: false
  require Logger

  alias Cforum.Repo

  def cleanup do
    from(user in User,
      where: is_nil(user.confirmed_at) and user.confirmation_sent_at <= datetime_add(^DateTime.utc_now(), -24, "hour")
    )
    |> Repo.all()
    |> Enum.each(fn user ->
      Logger.info("Automatically deleting user #{user.username}")
      Users.delete_user(nil, user)
    end)
  end
end
