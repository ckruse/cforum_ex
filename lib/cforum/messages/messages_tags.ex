defmodule Cforum.Messages.MessagesTags do
  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Messages.Message
  alias Cforum.Messages.Tag

  @doc """
  Returns a list of messages for a tag, limited to the forums specified in `visible_forums`

  ## Examples

      iex> list_messages_for_tag([%Forum{}], %Tag{}, limit: [quantity: 10, offset: 0])
      [%Message{}, ...]
  """
  def list_messages_for_tag(visible_forums, tag, query_params \\ [order: nil, limit: nil]) do
    forum_ids = Enum.map(visible_forums, & &1.forum_id)

    from(
      m in Message,
      inner_join: t in "messages_tags",
      on: t.message_id == m.message_id,
      preload: [:user, [thread: :forum]],
      where: t.tag_id == ^tag.tag_id and m.deleted == false and m.forum_id in ^forum_ids
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
    |> Repo.preload(tags: from(t in Tag, order_by: [asc: :tag_name]))
  end

  @doc """
  Counts the messages for a tag, limited to the forums specified in `visible_forums`

  ## Examples

      iex> count_messages_for_tag([%Forum{}], %Tag{})
      10
  """
  def count_messages_for_tag(visible_forums, tag) do
    forum_ids = Enum.map(visible_forums, & &1.forum_id)

    from(
      m in Message,
      inner_join: t in "messages_tags",
      on: t.message_id == m.message_id,
      where: t.tag_id == ^tag.tag_id and m.deleted == false and m.forum_id in ^forum_ids,
      select: count("*")
    )
    |> Repo.one()
  end
end
