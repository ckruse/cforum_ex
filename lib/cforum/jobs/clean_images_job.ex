defmodule Cforum.Jobs.CleanImagesJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  import Ecto.Query, warn: false

  alias Cforum.Repo

  alias Cforum.Media
  alias Cforum.Media.Image

  def perform(_) do
    Repo.transaction(
      fn ->
        from(image in Image,
          left_join: msg in assoc(image, :messages),
          where: is_nil(msg.message_id),
          where: image.created_at < fragment("NOW() - INTERVAL '14 days'")
        )
        |> Repo.stream()
        |> Enum.each(&Media.delete_image(&1, nil))
      end,
      timeout: :infinity
    )
  end
end
