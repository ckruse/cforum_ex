defmodule Cforum.Media.Image do
  use CforumWeb, :model

  @primary_key {:medium_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :medium_id}

  schema "media" do
    field(:content_type, :string)
    field(:filename, :string)
    field(:orig_name, :string)

    belongs_to(:owner, Cforum.Users.User, references: :user_id)

    timestamps(inserted_at: :created_at)
  end

  @doc false
  @spec changeset(%Cforum.Media.Image{}, %Cforum.Users.User{}, %Plug.Upload{}) :: %Ecto.Changeset{}
  def changeset(image, user, file) do
    image
    |> cast(%{}, [])
    |> maybe_set_owner_id(user)
    |> put_change(:content_type, file.content_type)
    |> put_change(:orig_name, file.filename)
    |> put_change(:filename, gen_filename(Path.extname(file.filename)))
    |> validate_format(:orig_name, ~r/\.(png|jpe?g|gif|svg)$/)
    |> validate_content_type(file)
    |> validate_required([:filename, :orig_name, :content_type])
    |> unique_constraint(:filename, name: :index_media_on_filename)
  end

  defp gen_filename(suffix, tries \\ 0)

  defp gen_filename(suffix, tries) when tries < 15 do
    fname = UUID.uuid1() <> suffix
    path = "#{Application.get_env(:cforum, :media_dir)}/#{fname}"

    if File.exists?(path),
      do: gen_filename(suffix, tries + 1),
      else: fname
  end

  defp gen_filename(_, _), do: nil

  defp maybe_set_owner_id(changeset, nil), do: changeset
  defp maybe_set_owner_id(changeset, user), do: put_change(changeset, :owner_id, user.user_id)

  defp validate_content_type(changeset, file) do
    if file.content_type =~ ~r/^image\/(png|gif|jpeg|svg\+xml)$/,
      do: changeset,
      else: add_error(changeset, :filename, "only image files are allowed!")
  end
end
