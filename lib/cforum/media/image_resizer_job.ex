defmodule Cforum.Media.ImageResizerJob do
  use Appsignal.Instrumentation.Decorators

  alias Cforum.Media

  def resize_image({:ok, img}) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      resize_image(img, "thumb")
      resize_image(img, "medium")
    end)

    {:ok, img}
  end

  def resize_image(val), do: val

  @decorate transaction()
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
