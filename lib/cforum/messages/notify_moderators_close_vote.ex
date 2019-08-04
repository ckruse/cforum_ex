defmodule Cforum.Messages.NotifyModeratorsCloseVote do
  import CforumWeb.Gettext

  alias Cforum.Repo

  alias Cforum.Messages
  alias Cforum.Accounts.Users
  alias Cforum.Abilities
  alias Cforum.ConfigManager
  alias Cforum.Accounts.Notifications
  alias CforumWeb.Views.ViewHelpers.Path

  def perform_new_vote(vote) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      msg =
        vote.message_id
        |> Messages.get_message!(view_all: true)
        |> Repo.preload(thread: :forum)

      msg.thread.forum
      |> Users.list_moderators()
      |> Repo.preload(badges_users: :badge)
      |> Enum.filter(&Abilities.access_forum?(&1, msg.thread.forum, :moderate))
      |> Enum.each(&notify_user(&1, vote, msg, ConfigManager.uconf(&1, "notify_on_open_close_vote")))
    end)
  end

  defp notify_user(user, vote, message, notify_type) when notify_type in ~w(yes email) do
    [subject, notification_type] =
      if vote.vote_type do
        [
          gettext("a new reopen vote has been created for message „%{subject}“", subject: message.subject),
          "reopen_vote:create"
        ]
      else
        [
          gettext("a new close vote has been created for message „%{subject}“", subject: message.subject),
          "close_vote:create"
        ]
      end

    if notify_type == "email" do
      user
      |> CforumWeb.NotificationMailer.new_open_close_vote(message.thread, message, vote, subject)
      |> Cforum.Mailer.deliver_later()
    end

    Notifications.create_notification(%{
      recipient_id: user.user_id,
      subject: subject,
      oid: message.message_id,
      otype: notification_type,
      path: Path.message_path(CforumWeb.Endpoint, :show, message.thread, message)
    })
  end

  defp notify_user(_user, _vote, _message, _notify_type), do: nil

  def perform_finish_vote(vote) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      msg =
        vote.message_id
        |> Messages.get_message!(view_all: true)
        |> Repo.preload(thread: :forum)

      msg.thread.forum
      |> Users.list_moderators()
      |> Repo.preload(badges_users: :badge)
      |> Enum.filter(&Abilities.access_forum?(&1, msg.thread.forum, :moderate))
      |> Enum.each(&notify_user_finish(&1, vote, msg, ConfigManager.uconf(&1, "notify_on_open_close_vote")))
    end)
  end

  defp notify_user_finish(user, vote, message, notify_type) when notify_type in ~w(yes email) do
    [subject, notification_type] =
      if vote.vote_type do
        [
          gettext("a reopen vote has been finished for message „%{subject}“", subject: message.subject),
          "reopen_vote:finish"
        ]
      else
        [
          gettext("a close vote has been finished for message „%{subject}“", subject: message.subject),
          "close_vote:finish"
        ]
      end

    if notify_type == "email" do
      user
      |> CforumWeb.NotificationMailer.finished_open_close_vote(message.thread, message, vote, subject)
      |> Cforum.Mailer.deliver_later()
    end

    Notifications.create_notification(%{
      recipient_id: user.user_id,
      subject: subject,
      oid: message.message_id,
      otype: notification_type,
      path: Path.message_path(CforumWeb.Endpoint, :show, message.thread, message)
    })
  end

  defp notify_user_finish(_user, _vote, _message, _notify_type), do: nil
end
