defmodule CforumWeb.Avatar do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Waffle.Ecto.Definition

  @versions [:original, :medium, :thumb]

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Whitelist file extensions:
  # def validate({file, _}) do
  #   ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  # end

  # Define a thumbnail transformation:
  # def transform(:thumb, _) do
  #   {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  # end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  def transform(:thumb, _), do: {:convert, "-strip -thumbnail 20x20^ -gravity center -extent 20x20"}
  def transform(:medium, _), do: {:convert, "-strip -thumbnail 100x100^ -gravity center -extent 100x100"}
  def transform(:original, _), do: :noaction

  defp id_partition(id) do
    Integer.to_string(id)
    |> String.pad_leading(9, "0")
    |> String.split(~r{(...)}, include_captures: true, trim: true)
    |> Enum.join("/")
  end

  def storage_dir_prefix() do
    Application.get_env(:cforum, :avatar_dir)
  end

  # Override the storage directory:
  def storage_dir(version, {_, scope}) do
    "#{Application.get_env(:cforum, :avatar_url)}/#{id_partition(scope.user_id)}/#{version}/"
  end

  # Provide a default URL if there hasn't been a file uploaded
  def default_url(version, _) do
    "/uploads/default_avatar/#{version}/missing.png"
  end
end
