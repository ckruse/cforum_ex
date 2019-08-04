defmodule CforumWeb.ImageView do
  use CforumWeb, :view

  alias Cforum.Abilities
  alias Cforum.Helpers

  alias CforumWeb.Paginator
  alias CforumWeb.Sortable
  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def page_heading(action, assigns), do: page_title(action, assigns)
  def page_title(_, _), do: gettext("images")
  def body_id(_, _), do: "images-index"
  def body_classes(_, _), do: "images index"

  def thumbnail_img(conn, img),
    do: {:safe, "<img src=\"#{Path.image_path(conn, :show, img, size: "thumb")}\" alt=\"\">"}
end
