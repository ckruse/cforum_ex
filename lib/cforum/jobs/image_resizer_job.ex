defmodule Cforum.Jobs.ImageResizerJob do
  use Oban.Worker, queue: :media, max_attempts: 5
  alias Cforum.Media

  def enqueue(img) do
    %{"medium_id" => img.medium_id}
    |> Cforum.Jobs.ImageResizerJob.new()
    |> Oban.insert!()
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"medium_id" => id}}) do
    if Application.get_env(:cforum, :environment) != :test do
      img = Media.get_image!(id)
      resize_image(img, "thumb")
      resize_image(img, "medium")
    end

    :ok
  end

  defp resize_image(img, version) do
    arguments = convert_arguments(img, version)
    convert = Application.get_env(:cforum, :convert)
    Porcelain.exec(convert, arguments)
  end

  defp convert_arguments(img, version) do
    orig_path = Media.future_image_path(img, "orig")
    version_path = Media.future_image_path(img, version)

    [
      orig_path,
      "-auto-orient",
      "-strip",
      args_by_version(version),
      version_path
    ]
    |> List.flatten()
  end

  defp args_by_version("thumb"), do: ["-thumbnail", "100x100>"]
  defp args_by_version("medium"), do: ["-scale", "800x600>"]
end
