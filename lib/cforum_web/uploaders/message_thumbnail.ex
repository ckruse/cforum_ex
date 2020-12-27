defmodule CforumWeb.MessageThumbnail do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Waffle.Ecto.Definition

  @versions [:original]

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

  def transform(:original, _), do: :noaction

  def storage_dir_prefix() do
    Application.get_env(:cforum, :thumbnail_dir)
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, message}) do
    "#{Application.get_env(:cforum, :thumbnail_url)}/#{message.message_id}/"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, _) do
  #   "/uploads/default_avatar/#{version}/missing.png"
  # end
end
