defmodule CforumWeb.ModerationView do
  use CforumWeb, :view

  alias Cforum.ModerationQueue.ModerationQueueEntry

  def page_heading(action, assigns), do: page_title(action, assigns)

  def page_title(_, _), do: gettext("moderation")

  def body_id(:index, _), do: "moderation-index"

  def body_classes(:index, _), do: "moderation index"

  def l10n_report_reason(%ModerationQueueEntry{reason: "off-topic"}), do: gettext("message is off topic")
  def l10n_report_reason(%ModerationQueueEntry{reason: "not-constructive"}), do: gettext("message is not constructive")
  def l10n_report_reason(%ModerationQueueEntry{reason: "illegal"}), do: gettext("message is illegal")
  def l10n_report_reason(%ModerationQueueEntry{reason: "spam"}), do: gettext("message is spam")
  def l10n_report_reason(%ModerationQueueEntry{reason: "custom"} = entry), do: entry.custom_reason

  def l10n_report_reason(%ModerationQueueEntry{reason: "duplicate"} = entry),
    do: gettext("message is a duplicate of %{url}", entry.duplicate_url)

  def l10n_resolution_action("close"), do: gettext("close message and children")
  def l10n_resolution_action("delete"), do: gettext("delete message and children")
  def l10n_resolution_action("no-archive"), do: gettext("set message and children to „no archive“")
  def l10n_resolution_action("manual"), do: gettext("manual intervention")
  def l10n_resolution_action("none"), do: gettext("no intervention")

  def closer_link(conn, entry) do
    {:safe, link} = user_link(conn, entry.closer, [], entry.closer_name)
    link
  end
end
