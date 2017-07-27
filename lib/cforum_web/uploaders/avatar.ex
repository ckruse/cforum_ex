defmodule CforumWeb.Avatar do
  use Arc.Definition
  use Arc.Ecto.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

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

  defp id_partition(id) do
    Integer.to_string(id)
    |> String.pad_leading(9, "0")
    |> String.split(~r{(...)}, include_captures: true, trim: true)
    |> Enum.join("/")
  end

  # Override the storage directory:
  def storage_dir(version, {_, scope}) do
    "priv/uploads/users/avatars/#{id_partition(scope.user_id)}/#{version}/"
  end

  # Provide a default URL if there hasn't been a file uploaded
  def default_url(version, _) do
    "/uploads/default_avatar/#{version}/missing.png"
  end
end
