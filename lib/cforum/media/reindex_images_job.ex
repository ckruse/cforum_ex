defmodule Cforum.Media.ReindexImagesJob do
  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Media.Image
  alias Cforum.Messages.Message

  @batch_size 100

  def perform do
    Task.start(&reindex_images/0)
  end

  def reindex_images(page \\ 0) do
    row_offset = page * @batch_size

    cnt =
      from(image in Image, order_by: [desc: :medium_id], limit: @batch_size, offset: ^row_offset)
      |> Repo.all()
      |> Enum.reduce(0, fn image, acc ->
        path = CforumWeb.Views.ViewHelpers.Path.image_path(CforumWeb.Endpoint, :show, image)

        messages =
          from(message in Message, where: like(message.content, ^"%#{path}%"))
          |> Repo.all()

        if messages != [] do
          {:ok, _} =
            image
            |> Repo.preload([:messages])
            |> Ecto.Changeset.change(%{updated_at: image.updated_at})
            |> Ecto.Changeset.put_assoc(:messages, messages)
            |> Repo.update()
        end

        acc + 1
      end)

    if cnt == @batch_size,
      do: reindex_images(page + 1)
  end
end
