defmodule Cforum.Forums.Thread do
  use CforumWeb, :model

  @primary_key {:thread_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :thread_id}

  def default_preloads, do: [:forum]
  def default_preloads(:messages), do: [:forum, messages: Cforum.Forums.Message.default_preloads()]

  schema "threads" do
    field(:archived, :boolean, default: false)
    field(:tid, :integer)
    field(:deleted, :boolean, default: false)
    field(:sticky, :boolean, default: false)
    field(:flags, :map, default: %{})
    field(:latest_message, Timex.Ecto.DateTime)
    field(:slug, :string)
    field(:subject, :string, virtual: true)

    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
    # belongs_to :message, Cforum.Forums.Message, references: :message_id
    has_many(:messages, Cforum.Forums.Message, foreign_key: :thread_id)

    field(:message, :any, virtual: true)
    field(:sorted_messages, :any, virtual: true)
    field(:tree, :any, virtual: true)
    field(:accepted, :any, virtual: true)
    field(:attribs, :map, virtual: true, default: %{classes: []})

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params, forum, visible_forums) do
    struct
    |> cast(params, [:forum_id, :subject])
    |> maybe_put_forum_id(forum)
    |> maybe_error_forum_id(visible_forums)
    |> gen_slug()
    |> validate_required([:forum_id, :slug, :latest_message])
  end

  defp maybe_put_forum_id(changeset, nil), do: changeset
  defp maybe_put_forum_id(changeset, %Cforum.Forums.Forum{forum_id: id}), do: put_change(changeset, :forum_id, id)

  defp maybe_error_forum_id(changeset, visible_forums) do
    case get_field(changeset, :forum_id) do
      nil ->
        changeset

      forum_id ->
        if Enum.find(visible_forums, &(&1.forum_id == forum_id)) == nil,
          do: add_error(changeset, :forum_id, "is invalid"),
          else: changeset
    end
  end

  defp gen_slug(changeset, num \\ 0) do
    case get_field(changeset, :subject) do
      subject when is_nil(subject) or subject == "" ->
        changeset

      subject ->
        now = Timex.local()
        s = Timex.format!(now, "/%Y/%b/%d/", :strftime) <> maybe_add_num(num) <> to_url(subject)

        if Cforum.Forums.Threads.slug_taken?(s),
          do: gen_slug(changeset, num + 1),
          else: put_change(changeset, :slug, s)
    end
  end

  defp to_url(str) do
    case Slug.slugify(str) do
      nil ->
        Ecto.UUID.generate()

      slug ->
        slug
    end
  end

  defp maybe_add_num(num) when is_nil(num) or num == 0, do: ""
  defp maybe_add_num(num), do: "#{num}-"
end
