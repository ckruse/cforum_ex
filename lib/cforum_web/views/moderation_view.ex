defmodule CforumWeb.ModerationView do
  use CforumWeb, :view

  alias Cforum.Abilities
  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  alias Cforum.ModerationQueue.ModerationQueueEntry

  def page_title(_, _), do: gettext("moderation")

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "moderation-index"
  def body_id(:index_open, _), do: "moderation-index-open"
  def body_id(:show, _), do: "moderation-show"
  def body_id(action, _) when action in [:edit, :update], do: "moderation-edit"

  def body_classes(:index, _), do: "moderation index"
  def body_classes(:index_open, _), do: "moderation index open"
  def body_classes(:show, _), do: "moderation show"
  def body_classes(action, _) when action in [:edit, :update], do: "moderation update"

  def l10n_report_reason(%ModerationQueueEntry{reason: "off-topic"}), do: gettext("message is off topic")
  def l10n_report_reason(%ModerationQueueEntry{reason: "not-constructive"}), do: gettext("message is not constructive")
  def l10n_report_reason(%ModerationQueueEntry{reason: "illegal"}), do: gettext("message is illegal")
  def l10n_report_reason(%ModerationQueueEntry{reason: "spam"}), do: gettext("message is spam")
  def l10n_report_reason(%ModerationQueueEntry{reason: "custom"} = entry), do: entry.custom_reason

  def l10n_report_reason(%ModerationQueueEntry{reason: "duplicate"} = entry),
    do: gettext("message is a duplicate of %{url}", url: entry.duplicate_url)

  def l10n_report_reason(%ModerationQueueEntry{reason: reason}), do: reason

  def l10n_resolution_action("close"), do: gettext("close message and children")
  def l10n_resolution_action("delete"), do: gettext("delete message and children")
  def l10n_resolution_action("no-archive"), do: gettext("set message and children to „no archive“")
  def l10n_resolution_action("manual"), do: gettext("manual intervention")
  def l10n_resolution_action("none"), do: gettext("no intervention")

  def l10n_resolution_action(action), do: action

  def closer_link(conn, entry) do
    {:safe, link} =
      if Helpers.present?(entry.closer_id),
        do: ViewHelpers.user_link(conn, entry.closer, [], entry.closer_name),
        else: {:safe, entry.closer_name}

    link
  end
end
