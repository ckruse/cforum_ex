defmodule CforumWeb.Blog.RedirectController do
  use CforumWeb, :controller

  alias Cforum.Abilities

  alias CforumWeb.Views.ViewHelpers.Path

  def redirect_users(conn, _) do
    conn
    |> put_status(301)
    |> redirect(external: Path.user_path(conn, :index))
  end

  def redirect_user(conn, %{"id" => id}) do
    conn
    |> put_status(301)
    |> redirect(external: Path.user_path(conn, :show, %{user_id: id}))
  end

  def allowed?(conn, _, _), do: Abilities.access_forum?(conn)
end
