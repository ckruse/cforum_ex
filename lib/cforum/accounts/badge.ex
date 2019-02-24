defmodule Cforum.Accounts.Badge do
  use CforumWeb, :model

  @primary_key {:badge_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :badge_id}

  @upvote "upvote"
  def upvote, do: @upvote

  @downvote "downvote"
  def downvote, do: @downvote

  @retag "retag"
  def retag, do: @retag

  @visit_close_reopen "visit_close_reopen"
  def visit_close_reopen, do: @visit_close_reopen

  @create_tags "create_tag"
  def create_tags, do: @create_tags

  @create_tag_synonym "create_tag_synonym"
  def create_tag_synonym, do: @create_tag_synonym

  @edit_question "edit_question"
  def edit_question, do: @edit_question

  @edit_answer "edit_answer"
  def edit_answer, do: @edit_answer

  @create_close_reopen_vote "create_close_reopen_vote"
  def create_close_reopen_vote, do: @create_close_reopen_vote

  @moderator_tools "moderator_tools"
  def moderator_tools, do: @moderator_tools

  @seo_profi "seo_profi"
  def seo_profi, do: @seo_profi

  @badge_types [
    @upvote,
    @downvote,
    @retag,
    @visit_close_reopen,
    @create_tags,
    @create_tag_synonym,
    @edit_question,
    @edit_answer,
    @create_close_reopen_vote,
    @moderator_tools,
    @seo_profi,
    "custom"
  ]
  def badge_types(), do: @badge_types

  @badge_medal_types ~w[bronze silver gold]
  def badge_medal_types(), do: @badge_medal_types

  schema "badges" do
    field(:score_needed, :integer)
    field(:name, :string)
    field(:description, :string)
    field(:slug, :string)
    field(:badge_medal_type, :string)
    field(:badge_type, :string)
    field(:order, :integer)

    has_many(:badges_users, Cforum.Accounts.BadgeUser, foreign_key: :badge_id)
    has_many(:users, through: [:badges_users, :user])

    many_to_many(:badges, Cforum.Accounts.BadgeGroup,
      join_through: "badges_badge_groups",
      on_delete: :delete_all,
      join_keys: [badge_id: :badge_id, badge_group_id: :badge_group_id]
    )

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:score_needed, :name, :description, :slug, :badge_medal_type, :badge_type, :order])
    |> validate_required([:name, :slug, :badge_medal_type, :badge_type, :order])
    |> unique_constraint(:slug, name: :badges_slug_key)
    |> unique_constraint(:badge_type, name: :badges_badge_type_idx)
    |> validate_inclusion(:badge_type, @badge_types)
    |> validate_inclusion(:badge_medal_type, @badge_medal_types)
  end
end
