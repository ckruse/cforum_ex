defmodule Cforum.Jobs.UserMailerJob do
  use Oban.Worker, queue: :mails, max_attempts: 5

  alias Cforum.Users

  @impl Oban.Worker
  def perform(%{"user_id" => id, "type" => "reset_password"}, _) do
    user = Users.get_user!(id)

    user
    |> Users.get_reset_password_token()
    |> CforumWeb.UserMailer.reset_password_mail()
    |> Cforum.Mailer.deliver!()

    :ok
  end

  def perform(%{"user_id" => id, "type" => "confirm_user"}, _) do
    user = Users.get_user!(id)

    user
    |> CforumWeb.UserMailer.confirmation_mail()
    |> Cforum.Mailer.deliver!()

    :ok
  end

  def enqueue(user, type) do
    %{"user_id" => user.user_id, "type" => type}
    |> Cforum.Jobs.UserMailerJob.new()
    |> Oban.insert!()
  end
end
