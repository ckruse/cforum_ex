defmodule Cforum.Jobs.IndexMessageImagesJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  import Ecto.Query, warn: false

  alias Cforum.Repo

  alias Cforum.Messages
  alias Cforum.Media
  alias Cforum.Media.Image

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"message_id" => mid}}) do
    message = Messages.get_message!(mid)

    Repo.transaction(fn ->
      from(m in "messages_media", where: m.message_id == ^message.message_id)
      |> Repo.delete_all()

      with {_, blocks, warnings} <- EarmarkParser.as_ast(message.content, smartypants: true, gfm: true, breaks: false),
           false <- has_errors?(warnings) do
        blocks
        |> find_images_in_blocks()
        |> Enum.filter(fn
          "/images/" <> _uuid -> true
          _ -> false
        end)
        |> Enum.each(fn "/images/" <> image_url ->
          filename = String.replace(image_url, ~r/\?[^?]+$/, "")

          with %Image{} = image <- Media.get_image_by_filename(filename, with: [:messages]) do
            messages = Enum.reject(image.messages, &(&1.message_id == message.message_id))

            image
            |> Ecto.Changeset.change(%{updated_at: image.updated_at})
            |> Ecto.Changeset.put_assoc(:messages, [message | messages])
            |> Repo.update()
          end
        end)
      end
    end)

    :ok
  end

  defp has_errors?(warnings) do
    Enum.find(warnings, fn
      {:error, _, _} -> true
      _ -> false
    end) != nil
  end

  defp find_images_in_blocks(blocks, images \\ []) do
    Enum.reduce(blocks, images, fn
      {"img", attrs, _, _}, images ->
        attrs
        |> Enum.find(fn
          {"src", src} -> src
          _ -> nil
        end)
        |> case do
          {_, src} -> [src | images]
          _ -> images
        end

      {_, _, children, _}, images ->
        find_images_in_blocks(children, images)

      _, images ->
        images
    end)
  end

  def enqueue(message_ids) when is_list(message_ids) do
    Enum.each(message_ids, fn id ->
      %{"message_id" => id}
      |> Cforum.Jobs.IndexMessageImagesJob.new()
      |> Oban.insert!()
    end)
  end

  def enqueue(message) do
    %{"message_id" => message.message_id}
    |> Cforum.Jobs.IndexMessageImagesJob.new()
    |> Oban.insert!()
  end
end
