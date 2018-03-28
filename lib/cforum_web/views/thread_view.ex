defmodule CforumWeb.ThreadView do
  use CforumWeb, :view

  alias Cforum.Forums.Thread

  defp archived_class(classes, %Thread{archived: true}), do: ["archived" | classes]
  defp archived_class(classes, _), do: classes

  defp sticky_class(classes, %Thread{sticky: true}), do: ["sticky" | classes]
  defp sticky_class(classes, _), do: classes

  defp no_archive_class(classes, %Thread{flags: %{"no-archive" => "yes"}}), do: ["no-archive" | classes]
  defp no_archive_class(classes, _), do: classes

  def thread_classes(thread) do
    thread.attribs[:classes]
    |> archived_class(thread)
    |> sticky_class(thread)
    |> no_archive_class(thread)
    |> Enum.join(" ")
  end

  def page_title(:index, assigns) do
    f = assigns[:current_forum]

    title = if f, do: f.name, else: gettext("all forums")
    gettext("overview") <> " — " <> title
  end

  def page_title(action, _assigns) when action in [:new, :create], do: gettext("new thread")

  def page_heading(action, assigns) when action in [:new, :create], do: page_title(action, assigns)

  def body_id(:index, _assigns), do: "threads-index"
  def body_classes(:index, assigns), do: "threads forum-#{forum_slug(assigns[:current_forum])}"
end
