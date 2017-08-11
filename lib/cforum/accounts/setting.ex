defmodule Cforum.Accounts.Setting do
  use CforumWeb, :model

  @primary_key {:setting_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :setting_id}

  schema "settings" do
    field :options, :map
    belongs_to :forum, Cforum.Forums.Forum, references: :forum_id
    belongs_to :user, Cforum.Accounts.User, references: :user_id
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:options, :forum_id, :user_id])
    |> validate_required([:options])
    |> unique_constraint(:forum_id)
  end
end
