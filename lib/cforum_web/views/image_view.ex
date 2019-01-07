defmodule CforumWeb.ImageView do
	use CforumWeb, :view

  def page_heading(action, assigns), do: page_title(action, assigns)
  def page_title(_, _), do: gettext("images")
  def body_id(_, _), do: "images-index"
  def body_classes(_, _), do: "images index"

  def thumbnail_img(conn, img),
    do: {:safe, "<img src=\"#{Routes.image_path(conn, :show, img.filename, size: "thumb")}\" alt=\"\">"}
end
