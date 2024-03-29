defmodule Cforum.InterestingMessages do
  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Messages.Message
  alias Cforum.InterestingMessages.InterestingMessage
  alias Cforum.Tags.Tag

  @doc """
  Marks a message as interesting for a user.

  ## Examples

  iex> mark_message_interesting(%User{}, %Message{})
  {:ok, %InterestingMessage{}}
  """
  @spec mark_message_interesting(%{user_id: any}, %{message_id: any}) ::
          {:ok, InterestingMessage.t()} | {:error, Ecto.Changeset.t()}
  def mark_message_interesting(user, message) do
    %InterestingMessage{}
    |> InterestingMessage.changeset(%{user_id: user.user_id, message_id: message.message_id})
    |> Repo.insert()
  end

  @doc """
  Removes the interesting mark of a message for a user.

  ## Examples

  iex> mark_message_boring(%User{}, %Message{})
  {:ok, %InterestingMessage{}}
  """
  @spec mark_message_boring(%{user_id: any}, %{message_id: any}) ::
          {:ok, InterestingMessage.t()} | nil | {:error, Ecto.Changeset.t()}
  def mark_message_boring(user, message) do
    interesting_message =
      InterestingMessage
      |> Repo.get_by(user_id: user.user_id, message_id: message.message_id)

    if interesting_message,
      do: Repo.delete(interesting_message),
      else: nil
  end

  @doc """
  Lists the messages marked as interesting for a user.

  ## Examples

  iex> list_interesting_messages(%User{})
  [%Message{}, ...]
  """
  @spec list_interesting_messages(%{user_id: any}, maybe_improper_list | map) :: [Message.t()]
  def list_interesting_messages(user, query_params \\ [order: nil, limit: nil]) do
    from(
      msg in Message,
      join: s in InterestingMessage,
      on: s.message_id == msg.message_id,
      where: s.user_id == ^user.user_id,
      preload: [:user, thread: :forum]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
    |> Repo.preload(tags: from(t in Tag, order_by: [asc: :tag_name]))
  end

  @doc """
  Counts the messages marked as interesting for a user.

  ## Examples

      iex> count_interesting_messages(%User{})
      1
  """
  @spec count_interesting_messages(%{user_id: any}) :: non_neg_integer()
  def count_interesting_messages(user) do
    from(
      msg in Message,
      join: s in InterestingMessage,
      on: s.message_id == msg.message_id,
      where: s.user_id == ^user.user_id,
      select: count()
    )
    |> Repo.one()
  end
end
