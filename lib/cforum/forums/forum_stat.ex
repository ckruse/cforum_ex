defmodule Cforum.Forums.ForumStat do
  use CforumWeb, :model

  @primary_key {:forum_stat_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :forum_stat_id}

  schema "forum_stats" do
    field(:moment, :date)
    field(:messages, :integer)
    field(:threads, :integer)
    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:forum_id, :moment, :messages, :threads])
    |> validate_required([:forum_id, :moment, :messages, :threads])
    |> unique_constraint(:forum_id, name: :forum_stats_forum_id_moment_key)
  end
end
