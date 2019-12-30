defmodule Cforum.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo
  alias Cforum.System
  alias Cforum.Users.User
  alias Cforum.Media.Image

  @doc """
  Returns the list of media.

  ## Examples

      iex> list_media()
      [%Image{}, ...]

  """
  def list_images(query_params \\ [order: nil, limit: nil]) do
    Image
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
    |> Repo.preload([:owner])
  end

  def count_images do
    Image
    |> select(count("*"))
    |> Repo.one()
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

  @spec get_image_by_filename!(String.t()) :: %Image{}
  def get_image_by_filename!(filename), do: Repo.get_by!(Image, filename: filename)

  @doc """
  Creates a image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_image(%User{}, %Plug.Upload{}) :: {:ok, %Image{}} | {:error, %Ecto.Changeset{}}
  def create_image(user, file) do
    System.audited("create", user, fn ->
      ret =
        %Image{}
        |> Image.changeset(user, file)
        |> Repo.insert()

      with {:ok, img} <- ret do
        path = future_image_path(img, "orig")

        # ensure that the file exists
        File.mkdir_p(Path.dirname(path))

        if File.cp(file.path, path) == :ok,
          do: {:ok, img},
          else: {:error, nil}
      end
    end)
    |> maybe_resize_image()
  end

  defp maybe_resize_image({:ok, img}) do
    if img.content_type != "image/svg+xml",
      do: Cforum.Jobs.ImageResizerJob.enqueue(img)

    {:ok, img}
  end

  defp maybe_resize_image(val), do: val

  @doc """
  Deletes a Image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Image{} = image, user) do
    ret =
      System.audited("destroy", user, fn ->
        Repo.delete(image)
      end)

    with {:ok, img} <- ret do
      Enum.each(["orig", "thumb", "medium"], fn size ->
        with {:ok, path} <- image_full_path(image, size) do
          File.rm(path)
        end
      end)

      {:ok, img}
    end
  end

  def image_full_path(%Image{} = image, size) do
    path = Application.get_env(:cforum, :media_dir)
    size = valid_size(size)

    if File.exists?("#{path}/#{size}/#{image.filename}"),
      do: {:ok, "#{path}/#{size}/#{image.filename}"},
      else: {:fallback, "#{path}/#{image.filename}"}
  end

  def future_image_path(%Image{} = image, size) do
    path = Application.get_env(:cforum, :media_dir)
    size = valid_size(size)

    "#{path}/#{size}/#{image.filename}"
  end

  defp valid_size("medium"), do: "medium"
  defp valid_size("thumb"), do: "thumb"
  defp valid_size(_), do: ""
end
