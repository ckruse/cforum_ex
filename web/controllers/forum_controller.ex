defmodule Cforum.ForumController do
  use Cforum.Web, :controller

  alias Cforum.Forum

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
