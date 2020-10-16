defmodule Cforum.Threads.Thread do
  use CforumWeb, :model

  alias Cforum.Threads.ThreadHelpers
  alias Cforum.Messages.Message
  alias Cforum.Forums.Forum

  @primary_key {:thread_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :thread_id}

  def default_preloads, do: [:forum]
  def default_preloads(:messages), do: [:forum, messages: Message.default_preloads()]

  schema "threads" do
    field(:archived, :boolean, default: false)
    field(:tid, :integer)
    field(:deleted, :boolean, default: false)
    field(:sticky, :boolean, default: false)
    field(:flags, :map, default: %{})
    field(:latest_message, :utc_datetime)
    field(:slug, :string)
    field(:subject, :string, virtual: true)

    belongs_to(:forum, Forum, references: :forum_id)
    # belongs_to :message, Message, references: :message_id
    has_many(:messages, Message, foreign_key: :thread_id)

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
  defp maybe_put_forum_id(changeset, %Forum{forum_id: id}), do: put_change(changeset, :forum_id, id)

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

        s =
          ((now
            |> Timex.lformat!("/%Y/%b/%d/", "en", :strftime)
            |> String.downcase()) <> maybe_add_num(num) <> to_url(subject))
          |> String.slice(0, 255)

        if ThreadHelpers.slug_taken?(s),
          do: gen_slug(changeset, num + 1),
          else: put_change(changeset, :slug, s)
    end
  end

  defp to_url(str) do
    case Slug.slugify(str) do
      nil -> UUID.uuid1()
      slug -> slug
    end
  end

  defp maybe_add_num(num) when is_nil(num) or num == 0, do: ""
  defp maybe_add_num(num), do: "#{num}-"
end
