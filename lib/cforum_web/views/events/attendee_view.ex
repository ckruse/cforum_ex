defmodule CforumWeb.Events.AttendeeView do
  use CforumWeb, :view

  alias Cforum.Abilities

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  def page_title(action, assigns) when action in [:new, :create],
    do: gettext("take place in event „%{event}“", event: assigns[:event].name)

  def page_title(action, assigns) when action in [:edit, :update] do
    gettext(
      "take place in event „%{event}“: attendee „%{attendee}“",
      event: assigns.event.name,
      attendee: assigns.attendee.name
    )
  end

  def page_heading(action, assigns), do: page_title(action, assigns)
  def body_id(action, _) when action in [:new, :create], do: "events-attendees-new"
  def body_classes(action, _) when action in [:new, :create], do: "events attendees new"
end
