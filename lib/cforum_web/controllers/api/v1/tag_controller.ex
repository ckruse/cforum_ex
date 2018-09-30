defmodule CforumWeb.Api.V1.TagController do
  use CforumWeb, :controller

  alias Cforum.Forums.Tags

  def index(conn, %{"f" => slug}) when slug != "" and slug != "all" do
    forum = Enum.find(conn.assigns[:visible_forums], &(&1.slug == slug))
    tags = Tags.list_tags(forum, conn.assigns[:visible_forums])
    render(conn, "index.json", tags: tags)
  end

  def index(conn, _params) do
    tags = Tags.list_tags(nil, conn.assigns[:visible_forums])
    render(conn, "index.json", tags: tags)
  end

  def allowed?(%{params: %{"f" => slug}} = conn, _, _) when slug != "" and slug != "all",
    do: Enum.find(conn.assigns[:visible_forums], &(&1.slug == slug)) != nil

  def allowed?(_conn, _, _), do: true
end
