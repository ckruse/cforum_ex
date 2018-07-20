defmodule CforumWeb.SearchController do
  use CforumWeb, :controller

  def allowed?(_, _, _), do: true
end
