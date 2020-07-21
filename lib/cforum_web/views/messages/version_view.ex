defmodule CforumWeb.Messages.VersionView do
  use CforumWeb, :view

  alias Cforum.Abilities
  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def page_title(_, assigns), do: gettext("versions of message „%{subject}“", subject: assigns.message.subject)

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(action, _), do: "message-versions-#{action}"

  def body_classes(action, _), do: "message versions #{action}"

  def diff_content(%{subject: subject, content: content}), do: "#{subject}\n\n#{content}"

  def version_list(message) do
    message.versions
    |> Enum.sort_by(& &1.message_version_id, &>=/2)
  end

  def can_delete?(conn, view_all, %{message_version_id: _} = version),
    do: view_all && Abilities.may?(conn, "messages/version", :delete, version)

  def can_delete?(_, _, _),
    do: false
end
