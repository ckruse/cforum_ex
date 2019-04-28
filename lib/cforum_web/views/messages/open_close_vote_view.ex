defmodule CforumWeb.Messages.OpenCloseVoteView do
  use CforumWeb, :view

  alias Cforum.Messages.CloseVote

  def page_title(action, assigns) when action in [:new_close, :create_close] do
    gettext(
      "Start a close vote for message %{subject} by %{author}",
      subject: assigns.message.subject,
      author: assigns.message.author
    )
  end

  def page_title(action, assigns) when action in [:new_open, :create_open] do
    gettext(
      "Start a reopen vote for message %{subject} by %{author}",
      subject: assigns.message.subject,
      author: assigns.message.author
    )
  end

  def page_heading(action, assigns), do: page_title(action, assigns)
  def body_id(action, _) when action in [:new_close, :create_close], do: "close-vote-message-new"
  def body_classes(action, _) when action in [:new_close, :create_close], do: "close-vote-message new"

  def l10n_reason("off-topic"), do: gettext("Message is off topic.")

  def l10n_reason("not-constructive"),
    do: gettext("message is unconstructive or provocative and contributes to a deterioration of sentiment")

  def l10n_reason("illegal"), do: gettext("message is illegal")
  def l10n_reason("duplicate"), do: gettext("message is a duplicate of another message")
  def l10n_reason("custom"), do: gettext("custom reason")
  def l10n_reason("spam"), do: gettext("message is spam")

  def l10n_action(conn, vote) do
    action = conf(conn, "close_vote_action_" <> vote.reason)

    if vote.finished,
      do: l10n_action_done(action),
      else: l10n_action(action)
  end

  def l10n_action("close"), do: gettext("Message and answers should be closed.")
  def l10n_action("hide"), do: gettext("Message and answers should be deleted.")

  def l10n_action_done("close"), do: gettext("message and answers have been closed")
  def l10n_action_done("hide"), do: gettext("message and answers have been deleted")
end
