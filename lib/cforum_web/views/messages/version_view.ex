defmodule CforumWeb.Messages.VersionView do
  use CforumWeb, :view

  def page_title(_, assigns), do: gettext("Edit versions of message „%{subject}“", subject: assigns.message.subject)
  def page_heading(action, assigns), do: page_title(action, assigns)
  def body_id(action, _) when action in [:new_close, :create_close], do: "message-versions"
  def body_classes(action, _) when action in [:new_close, :create_close], do: "message versions"

  def diff_content(%{subject: subject, content: content}), do: "#{subject}\n\n#{content}"

  def version_list(conn, thread, message, assigns) do
    {content, _} =
      message.versions
      |> Enum.sort_by(& &1.message_version_id, &>=/2)
      |> Enum.reduce({"", diff_content(message)}, fn version, {content, prev_content} ->
        dcontent = diff_content(version)

        {[
           content
           | render(
               "version.html",
               Map.merge(assigns, %{
                 conn: conn,
                 thread: thread,
                 message: message,
                 version: version,
                 prev_content: dcontent,
                 diff_content: prev_content
               })
             )
         ], dcontent}
      end)

    content
  end

  def diff_posting(old, new), do: Cforum.Diffing.diff(old, new)
end
