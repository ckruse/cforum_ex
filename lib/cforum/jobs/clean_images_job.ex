defmodule Cforum.Jobs.CleanImagesJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  import Ecto.Query, warn: false

  alias Cforum.Repo

  alias Cforum.Helpers.AsyncHelper

  alias Cforum.Media
  alias Cforum.Media.Image
  alias Cforum.Messages.Message

  @limit 100

  def perform(_) do
    delete_images(0)

    :ok
  end

  defp delete_images(offset) do
    images =
      from(image in Image,
        left_join: msg in assoc(image, :messages),
        where: is_nil(msg.message_id),
        where: image.created_at < fragment("NOW() - INTERVAL '14 days'"),
        limit: @limit,
        offset: ^offset
      )
      |> Repo.all()

    AsyncHelper.run_async(fn ->
      Enum.each(images, &delete_image/1)
    end)

    if images != [],
      do: delete_images(offset + @limit)
  end

  # just to be absolutely sure that we don't delete images that are still referenced we check again if the image
  # name is referenced somewhere in message contents
  defp delete_image(img) do
    fname = "%/images/#{img.filename}%"
    exists = from(msg in Message, where: like(msg.content, ^fname)) |> Repo.exists?()

    if !exists,
      do: Media.delete_image(img, nil)
  end
end
