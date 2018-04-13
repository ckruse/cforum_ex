defmodule CforumWeb.WidgetsView do
  use CforumWeb, :view

  def multi_users_selector(assigns, users, field_name) do
    render(
      "users_selector.html",
      Map.merge(assigns, %{users: users, field_name: field_name})
    )
  end
end
