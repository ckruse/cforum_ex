defmodule CforumWeb.Api.V1.ImageController do
  use CforumWeb, :controller

  alias Cforum.Media

  def create(conn, %{"image" => image_params}) do
    case Media.create_image(conn.assigns.current_user, image_params) do
      {:ok, image} -> json(conn, %{status: "success", location: Path.image_path(conn, :show, image)})
      {:error, _changeset} -> json(conn, %{status: "error"})
    end
  end

  def allowed?(_conn, _, _), do: true
end
