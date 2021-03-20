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
    orig_path = Media.future_image_path(img, "orig")
    version_path = Media.future_image_path(img, version)
    arguments = convert_arguments(version, orig_path, version_path)
    convert = Application.get_env(:cforum, :convert)

    System.cmd(convert, arguments)

    if File.exists?(version_path <> ".tmp") do
      File.rename(version_path <> ".tmp", version_path)
    end
  end

  defp convert_arguments(version, orig_path, version_path) do
    [
      orig_path,
      "-auto-orient",
      "-strip",
      args_by_version(version),
      version_path <> ".tmp"
    ]
    |> List.flatten()
  end

  defp args_by_version("thumb"), do: ["-thumbnail", "100x100>"]
  defp args_by_version("medium"), do: ["-scale", "800x600>"]
end
