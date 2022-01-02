defmodule CforumWeb.ImageView do
  use CforumWeb, :view

  alias Cforum.Abilities
  alias Cforum.Helpers

  alias CforumWeb.Paginator
  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def page_heading(action, assigns), do: page_title(action, assigns)
  def page_title(:index, _), do: gettext("images")
  def page_title(:show, assigns), do: gettext("image „%{name}“", name: assigns[:image].orig_name)

  def body_id(:index, _), do: "images-index"
  def body_id(:show, _), do: "images-show"

  def body_classes(:index, _), do: "images index"
  def body_classes(:show, _), do: "images show"

  def thumbnail_img(conn, img) do
    [
      {:safe, "<img src=\""},
      Path.image_path(conn, :show, img, size: "thumb"),
      {:safe, "\" class=\"cf-images-index-preview-img\" alt=\"\">"}
    ]
  end
end
