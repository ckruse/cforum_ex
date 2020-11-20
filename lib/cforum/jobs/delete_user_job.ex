defmodule Cforum.Jobs.DeleteUserJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  alias Cforum.Repo

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => id, "executing_user_id" => euid}}) do
    user = Cforum.Users.get_user!(id)
    current_user = Cforum.Users.get_user!(euid)

    delete_user(user, current_user)

    :ok
  end

  def perform(%Oban.Job{args: %{"user_id" => id}}) do
    user = Cforum.Users.get_user!(id)
    delete_user(user, nil)

    :ok
  end

  def delete_user(user, current_user) do
    Cforum.System.audited("destroy", current_user, fn -> Repo.delete(user) end, timeout: :infinity)
    |> Cforum.Settings.discard_settings_cache()
    |> Cforum.Users.discard_user_cache()
    |> Cforum.Threads.ThreadCaching.refresh_cached_thread()
  end

  def enqueue(user, nil) do
    %{"user_id" => user.user_id}
    |> Cforum.Jobs.DeleteUserJob.new()
    |> Oban.insert!()
  end

  def enqueue(user, current_user) do
    %{"user_id" => user.user_id, "executing_user_id" => current_user.user_id}
    |> Cforum.Jobs.DeleteUserJob.new()
    |> Oban.insert!()
  end
end
