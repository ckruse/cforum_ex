defmodule Cforum.Web.ForumController do
  use Cforum.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
