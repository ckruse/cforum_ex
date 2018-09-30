defmodule CforumWeb.ImageController do
  use CforumWeb, :controller

  alias Cforum.Media

  @max_age 30 * 24 * 60 * 60

  def show(conn, %{"id" => id} = params) do
    img = Media.get_image_by_filename!(id)
    full_path = Media.image_full_path(img, params["size"])

    cache_end = Timex.shift(Timex.now(), days: 30)

    conn
    |> put_resp_content_type(img.content_type, nil)
    |> put_resp_header("Expires", Timex.format!(cache_end, "{RFC822}"))
    |> put_resp_header("Cache-Control", "public, max-age=#{@max_age}")
    |> send_file(200, full_path)
  end

  def allowed?(conn, :index, _), do: admin?(conn)
  def allowed?(conn, :delete, _), do: admin?(conn)
  def allowed?(_conn, _, _), do: true
end
