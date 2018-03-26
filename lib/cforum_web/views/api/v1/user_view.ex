defmodule CforumWeb.Api.V1.UserView do
  use CforumWeb, :view

  def render("index.json", %{users: users}), do: users
  def render("show.json", %{user: user}), do: user
end
