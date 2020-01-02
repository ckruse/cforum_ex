defmodule CforumWeb.Api.V1.TagController do
  use CforumWeb, :controller

  alias Cforum.Tags

  def index(conn, _params) do
    tags = Tags.list_tags()
    render(conn, "index.json", tags: tags)
  end

  def allowed?(_conn, _, _), do: true
end
