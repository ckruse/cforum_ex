defmodule Cforum.Accounts.Badge do
  use CforumWeb, :model

  @primary_key {:badge_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :badge_id}

  @upvote "upvote"
  def upvote, do: @upvote

  @downvote "downvote"
  def downvote, do: @downvote

  @flag "flag"
  def flag, do: @flag

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

  @badge_types [@upvote, @downvote, @flag,
                @retag, @visit_close_reopen, @create_tags,
                @create_tag_synonym, @edit_question, @edit_answer,
                @create_close_reopen_vote, @moderator_tools, @seo_profi, "custom"]

  @badge_medal_types ~w[bronze silver gold]

  schema "badges" do
    field :score_needed, :integer
    field :name, :string
    field :description, :string
    field :slug, :string
    field :badge_medal_type, :string
    field :badge_type, :string
    field :order, :integer

    has_many :badges_users, Cforum.Accounts.BadgeUser, foreign_key: :badge_id
    has_many :users, through: [:badges_users, :user]

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:score_needed, :name, :description, :slug,
                     :badge_medal_type, :badge_type, :order])
    |> validate_required([:name, :slug, :badge_medal_type, :badge_type, :order])
    |> unique_constraint(:slug)
    |> validate_inclusion(:badge_type, @badge_types)
    |> validate_inclusion(:badge_medal_type, @badge_medal_types)
    |> maybe_unique_badge_medal_type
  end

  defp maybe_unique_badge_medal_type(changeset) do
    case get_field(changeset, :badge_type) do
      "custom" -> changeset
      _ -> unique_constraint(changeset, :badge_medal_type)
    end
  end
end
