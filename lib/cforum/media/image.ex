defmodule Cforum.Media.Image do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:medium_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :medium_id}

  schema "media" do
    field(:content_type, :string)
    field(:filename, :string)
    field(:orig_name, :string)
    field(:owner_id, :id)

    timestamps(inserted_at: :created_at)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:filename, :orig_name, :content_type])
    |> validate_required([:filename, :orig_name, :content_type])
  end
end
