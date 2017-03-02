defmodule Cforum.MessageTag do
  use Cforum.Web, :model

  schema "messages_tags" do
    belongs_to :message, Cforum.Message
    belongs_to :tag, Cforum.Tag

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
