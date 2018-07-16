defmodule CforumWeb.Messages.FlagView do
  use CforumWeb, :view

  alias Cforum.Forums.ModerationQueueEntry

  def page_title(_, assigns) do
    gettext("flag message %{subject} by %{author}", subject: assigns.message.subject, author: assigns.message.author)
  end

  def page_heading(action, assigns), do: page_title(action, assigns)
  def body_id(_, _), do: "flag-message"
  def body_classes(_, _), do: "flag-message new"

  def l10n_reason("off-topic"), do: gettext("Message is off topic.")

  def l10n_reason("not-constructive"),
    do: gettext("message is unconstructive or provocative and contributes to a deterioration of sentiment")

  def l10n_reason("illegal"), do: gettext("message is illegal")
  def l10n_reason("duplicate"), do: gettext("message is a duplicate of another message")
  def l10n_reason("custom"), do: gettext("custom reason")
  def l10n_reason("spam"), do: gettext("message is spam")
end
