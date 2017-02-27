defmodule Cforum.Helpers do
  use Phoenix.HTML

  def signed_in?(conn) do
    conn.assigns[:current_user] != nil
  end
end
