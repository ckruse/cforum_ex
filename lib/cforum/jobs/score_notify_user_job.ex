defmodule Cforum.Jobs.ScoreNotifyUserJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  alias Cforum.Caching
  alias Cforum.Users.User

  @impl Oban.Worker
  def perform(%{"user_id" => uid, "value" => value, "action" => action}, _) do
    Caching.update(:cforum, "users/#{uid}", fn user ->
      if action == "delete",
        do: %User{user | score: user.score - value},
        else: %User{user | score: user.score + value}
    end)

    user = Cforum.Users.get_user!(uid)
    CforumWeb.Endpoint.broadcast!("users:#{user.user_id}", "score-update", %{value: value, score: user.score})

    :ok
  end

  def enqueue(score, action) do
    %{"user_id" => score.user_id, "value" => score.value, "action" => action}
    |> Cforum.Jobs.ScoreNotifyUserJob.new()
    |> Oban.insert!()
  end
end
