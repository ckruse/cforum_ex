defmodule Cforum.Forums.Votes do
  @moduledoc """
  The boundary for the Forums system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  import Cforum.Helpers

  alias Cforum.Accounts.Scores
  alias Cforum.Forums.Vote
  alias Cforum.Forums.{Messages, Message}

  alias Cforum.Forums.VoteBadgeDistributorJob

  @doc """
  Returns the list of votes.

  ## Examples

      iex> list_votes()
      [%Vote{}, ...]

  """
  def list_votes do
    Repo.all(Vote)
  end

  def count_votes_for_user(user, forum_ids) do
    from(
      v in Vote,
      select: count("*"),
      inner_join: m in Message,
      on: m.message_id == v.message_id,
      where: v.user_id == ^user.user_id,
      where: m.forum_id in ^forum_ids and m.deleted == false
    )
    |> Repo.one()
  end

  def list_votes_for_user(user, forum_ids, query_params \\ [limit: nil]) do
    from(
      v in Vote,
      inner_join: m in Message,
      on: m.message_id == v.message_id,
      preload: [:score, message: [:user, :tags, [thread: :forum, votes: :voters]]],
      where: v.user_id == ^user.user_id,
      where: m.forum_id in ^forum_ids and m.deleted == false,
      order_by: [desc: m.created_at]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Repo.all()
  end

  @doc """
  Gets a single vote.

  Raises `Ecto.NoResultsError` if the Vote does not exist.

  ## Examples

      iex> get_vote!(123)
      %Vote{}

      iex> get_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(id), do: Repo.get!(Vote, id)

  def get_vote!(message, user) do
    from(
      vote in Vote,
      where: vote.user_id == ^user.user_id and vote.message_id == ^message.message_id,
      preload: [:score, message: ^Message.default_preloads()]
    )
    |> Repo.one!()
  end

  def get_vote(message, user) do
    from(
      vote in Vote,
      where: vote.user_id == ^user.user_id and vote.message_id == ^message.message_id,
      preload: [:score, message: ^Message.default_preloads()]
    )
    |> Repo.one()
  end

  @doc """
  Creates a vote.

  ## Examples

      iex> create_vote(%{field: value})
      {:ok, %Vote{}}

      iex> create_vote(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vote(attrs \\ %{}) do
    %Vote{}
    |> Vote.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vote.

  ## Examples

      iex> update_vote(vote, %{field: new_value})
      {:ok, %Vote{}}

      iex> update_vote(vote, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vote(%Vote{} = vote, attrs) do
    vote
    |> Vote.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Vote.

  ## Examples

      iex> delete_vote(vote)
      {:ok, %Vote{}}

      iex> delete_vote(vote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vote(%Vote{} = vote) do
    Repo.delete(vote)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vote changes.

  ## Examples

      iex> change_vote(vote)
      %Ecto.Changeset{source: %Vote{}}

  """
  def change_vote(%Vote{} = vote) do
    Vote.changeset(vote, %{})
  end

  def voted?(%Message{__meta__: %{state: :built}}, _, _), do: false

  def voted?(message, user, type) when not is_nil(user) and type in ["upvote", "downvote"],
    do: present?(Enum.find(message.votes, fn vote -> vote.user_id == user.user_id && vote.vtype == type end))

  def voted?(_, _, _), do: false

  def downvoted?(message, user) when not is_nil(user), do: voted?(message, user, "downvote")
  def downvoted?(_, _), do: false
  def upvoted?(message, user) when not is_nil(user), do: voted?(message, user, "upvote")
  def upvoted?(_, _), do: false

  def take_back_vote(message, user) do
    Repo.transaction(fn ->
      with {:ok, val} <- remove_vote(message, user) do
        val
      end
    end)
  end

  def upvote(message, user, points) do
    Repo.transaction(fn ->
      remove_vote(message, user)
      Messages.score_up_message(message)

      {:ok, vote} = create_vote(%{message_id: message.message_id, user_id: user.user_id, vtype: "upvote"})

      if present?(message.user_id) do
        {:ok, _score} = Scores.create_score(%{vote_id: vote.vote_id, user_id: message.user_id, value: points})
      end

      Messages.update_cached_message(message, &%Message{&1 | votes: [vote | &1.votes]})

      vote
    end)
    |> VoteBadgeDistributorJob.grant_badges()
  end

  def downvote(message, user, points) do
    Repo.transaction(fn ->
      remove_vote(message, user)
      Messages.score_down_message(message)

      {:ok, vote} = create_vote(%{message_id: message.message_id, user_id: user.user_id, vtype: "downvote"})
      {:ok, _score} = Scores.create_score(%{vote_id: vote.vote_id, user_id: user.user_id, value: points})

      if present?(message.user_id) do
        {:ok, _score} = Scores.create_score(%{vote_id: vote.vote_id, user_id: message.user_id, value: points})
      end

      Messages.update_cached_message(message, &%Message{&1 | votes: [vote | &1.votes]})

      vote
    end)
    |> VoteBadgeDistributorJob.grant_badges()
  end

  defp remove_vote(message, user) do
    case get_vote(message, user) do
      nil ->
        nil

      vote ->
        if vote.vtype == Vote.upvote(),
          do: Messages.score_up_message(message, -1),
          else: Messages.score_down_message(message, -1)

        Scores.delete_scores_by_vote_id(user, vote.vote_id)

        with {:ok, vote} <- delete_vote(vote) do
          Messages.update_cached_message(message, fn msg ->
            %Message{msg | votes: Enum.reject(msg.votes, &(&1.vote_id == vote.vote_id))}
          end)

          {:ok, vote}
        end
    end
  end
end
