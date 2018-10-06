defmodule CforumWeb.Api.V1.ConfigController do
  use CforumWeb, :controller

  def show(conn, _params) do
    config = %{
      "max_tags_per_message" => conf(conn, "max_tags_per_message"),
      "min_tags_per_message" => conf(conn, "min_tags_per_message"),
      "header_start_index" => conf(conn, "header_start_index")
    }

    json(conn, config)
  end

  def allowed?(_conn, _, _), do: true
end
