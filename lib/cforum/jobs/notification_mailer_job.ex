defmodule Cforum.Jobs.NotificationMailerJob do
  use Oban.Worker, queue: :mails, max_attempts: 5

  @impl Oban.Worker
  def perform(%{"priv_message_id" => pmid, "user_id" => uid, "type" => "priv_message"}, _) do
    user = Cforum.Users.get_user!(uid)
    pm = Cforum.PrivMessages.get_priv_message!(user, pmid)

    user
    |> CforumWeb.NotificationMailer.pm_notification_mail(pm)
    |> Cforum.Mailer.deliver!()
  end

  def perform(%{"moderation_queue_entry_id" => modqid, "type" => "moderation_queue"}, _) do
    entry = Cforum.ModerationQueue.get_entry!(modqid)
    m = Cforum.Messages.get_message!(entry.message_id, view_all: true)
    forum = Cforum.Forums.get_forum!(m.forum_id)
    {thread, message} = Cforum.Messages.get_message_and_thread!(forum, nil, m.thread_id, m.message_id, view_all: true)

    forum
    |> Cforum.Users.list_moderators()
    |> Enum.filter(&(Cforum.ConfigManager.uconf(&1, "notify_on_flagged") == "email"))
    |> Enum.each(fn user ->
      user
      |> CforumWeb.NotificationMailer.moderation_mail(entry, thread, message)
      |> Cforum.Mailer.deliver!()
    end)
  end

  def enqueue_for_pm(pm, user) do
    %{"user_id" => user.user_id, "priv_message_id" => pm.priv_message_id, "type" => "priv_message"}
    |> Cforum.Jobs.NotificationMailerJob.new()
    |> Oban.insert!()
  end

  def enqueue_for_moderation_queue_entry(entry) do
    %{"moderation_queue_entry_id" => entry.moderation_queue_entry_id, "type" => "moderation_queue"}
    |> Cforum.Jobs.NotificationMailerJob.new()
    |> Oban.insert!()
  end
end
