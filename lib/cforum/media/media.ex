defmodule Cforum.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Media.Image

  @doc """
  Returns the list of media.

  ## Examples

      iex> list_media()
      [%Image{}, ...]

  """
  def list_images do
    Repo.all(Image)
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id), do: Repo.get!(Image, id)

  def get_image_by_filename!(filename), do: Repo.get_by!(Image, filename: filename)

  @doc """
  Creates a image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a image.

  ## Examples

      iex> update_image(image, %{field: new_value})
      {:ok, %Image{}}

      iex> update_image(image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.

  ## Examples

      iex> change_image(image)
      %Ecto.Changeset{source: %Image{}}

  """
  def change_image(%Image{} = image) do
    Image.changeset(image, %{})
  end

  def image_full_path(%Image{} = image, size) do
    path = Application.get_env(:cforum, :media_dir)
    size = valid_size(size)

    if File.exists?("#{path}/#{size}/#{image.filename}"),
      do: "#{path}/#{size}/#{image.filename}",
      else: "#{path}/#{image.filename}"
  end

  defp valid_size("medium"), do: "medium"
  defp valid_size("thumb"), do: "thumb"
  defp valid_size(_), do: ""
end
