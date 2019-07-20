defmodule CforumWeb.Api.V1.TagView do
  use CforumWeb, :view

  def render("index.json", %{tags: tags}), do: tags
end
