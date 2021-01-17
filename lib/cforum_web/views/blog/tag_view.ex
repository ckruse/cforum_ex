defmodule CforumWeb.Blog.TagView do
  use CforumWeb, :view

  alias CforumWeb.Paginator
  alias Cforum.Helpers

  alias CforumWeb.TagView, as: OrigTagView
  alias CforumWeb.Views.ViewHelpers.Path

  def page_title(:index, _), do: gettext("tags list")
  def page_title(:show, assigns), do: gettext("tag “%{tag}”", tag: assigns[:tag].tag_name)

  def body_id(:index, _), do: "tag-index"
  def body_id(:show, _), do: "tag-show"

  def body_classes(:index, _), do: "tag index"
  def body_classes(:show, assigns), do: "tag show #{assigns[:tag].slug}"

  def message_path(conn, :show, thread, _, params),
    do: Path.blog_thread_url(conn, :show, thread, params)
end
