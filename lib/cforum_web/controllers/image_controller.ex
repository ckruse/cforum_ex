defmodule CforumWeb.ImageController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.Media

  alias CforumWeb.Sortable
  alias CforumWeb.Paginator

  alias Cforum.Threads.Thread
  alias Cforum.Messages.Message

  @max_age 30 * 24 * 60 * 60

  def index(conn, params) do
    {sort_params, conn} = Sortable.sort_collection(conn, [:created_at, :name], dir: :desc)
    count = Media.count_images()
    paging = Paginator.paginate(count, page: params["p"])
    images = Media.list_images(limit: paging.params, order: sort_params)

    render(conn, "index.html", images: images, paging: paging)
  end

  def show(conn, %{"id" => id} = params) do
    if is_image_id(id),
      do: show_image_details(conn, params),
      else: show_image(conn, params)
  end

  defp show_image(conn, %{"id" => id} = params) do
    img = Media.get_image_by_filename!(id)

    case Media.image_full_path(img, params["size"]) do
      {:fallback, full_path} ->
        conn
        |> put_resp_content_type(img.content_type, nil)
        |> put_resp_header("Expires", "0")
        |> put_resp_header("Cache-Control", "no-cache, no-store, must-revalidate")
        |> put_resp_header("Pragma", "no-cache")
        |> send_file(200, full_path)

      {:ok, full_path} ->
        cache_end = Timex.shift(Timex.now(), days: 30)

        conn
        |> put_resp_content_type(img.content_type, nil)
        |> put_resp_header("Expires", Timex.format!(cache_end, "{RFC822}"))
        |> put_resp_header("Cache-Control", "public, max-age=#{@max_age}")
        |> send_file(200, full_path)
    end
  end

  defp show_image_details(conn, %{"id" => id} = _params) do
    img = Media.get_image!(id, with: [messages: [:user, [thread: :forum]]])

    messages =
      Enum.map(img.messages, fn msg ->
        thread = %Thread{msg.thread | message: msg}
        %Message{msg | thread: thread}
      end)

    render(conn, "show.html", image: img, messages: messages)
  end

  def delete(conn, %{"id" => id}) do
    img = Media.get_image!(id)
    {:ok, _img} = Media.delete_image(img, conn.assigns.current_user)

    conn
    |> put_flash(:info, gettext("Image deleted successfully."))
    |> redirect(to: Path.image_path(conn, :index))
  end

  def allowed?(conn, :index, _), do: Abilities.admin?(conn)
  def allowed?(conn, :delete, _), do: Abilities.admin?(conn)
  def allowed?(_conn, _, _), do: true

  defp is_image_id(param), do: Regex.match?(~r/^\d+$/, param)
end
