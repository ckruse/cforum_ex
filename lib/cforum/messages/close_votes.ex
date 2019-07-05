defmodule Cforum.Messages.CloseVotes do
  @moduledoc """
  The boundary for the Forums.CloseVotes system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo
  alias Cforum.Threads
  alias Cforum.Threads.ThreadCaching
  alias Cforum.Messages
  alias Cforum.Messages.MessageCaching
  alias Cforum.Messages.Message
  alias Cforum.Messages.{CloseVote, CloseVoteVoter}
  alias Cforum.System

  @doc """
  Returns the list of close_votes.

  ## Examples

      iex> list_close_votes()
      [%CloseVote{}, ...]

  """
  def list_votes(message) do
    from(ocv in CloseVote, where: ocv.message_id == ^message.message_id)
    |> Repo.all()
  end

  @doc """
  Gets a single vote.

  Raises `Ecto.NoResultsError` if the Open close vote does not exist.

  ## Examples

      iex> get_vote!(123)
      %CloseVote{}

      iex> get_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(id), do: Repo.get!(CloseVote, id)

  @doc """
  Creates a close vote.

  ## Examples

      iex> create_vote(%User{}, %Message{}, %{field: value})
      {:ok, %CloseVote{}}

      iex> create_vote(%User{}, %Message{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vote(user, message, attrs \\ %{}) do
    System.audited("create", nil, fn ->
      ret =
        %CloseVote{message_id: message.message_id}
        |> CloseVote.new_changeset(attrs)
        |> Repo.insert()

      with {:ok, close_vote} <- ret,
           {:ok, _vote} <- vote(user, close_vote) do
        {:ok, %CloseVote{close_vote | voters: list_voters(close_vote)}}
      end
    end)
    |> MessageCaching.update_cached_message()
  end

  @doc """
  Creates a reopen vote.

  ## Examples

      iex> create_reopen_vote(%User{}, %Message{}, %{field: value})
      {:ok, %CloseVote{vote_type: true}}

      iex> create_reopen_vote(%User{}, %Message{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_reopen_vote(user, message, attrs \\ %{}) do
    System.audited("create", nil, fn ->
      ret =
        %CloseVote{message_id: message.message_id}
        |> CloseVote.new_open_changeset(attrs)
        |> Repo.insert()

      with {:ok, close_vote} <- ret,
           {:ok, _vote} <- vote(user, close_vote) do
        {:ok, close_vote}
      end
    end)
    |> MessageCaching.update_cached_message()
  end

  @doc """
  Updates a vote.

  ## Examples

      iex> update_vote(vote, %{field: new_value})
      {:ok, %CloseVote{}}

      iex> update_vote(vote, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vote(current_user, %CloseVote{} = vote, attrs) do
    System.audited("vote", current_user, fn ->
      vote
      |> CloseVote.new_changeset(attrs)
      |> Repo.update()
    end)
    |> MessageCaching.update_cached_message()
  end

  @doc """
  Deletes a CloseVote.

  ## Examples

      iex> delete_vote(vote)
      {:ok, %CloseVote{}}

      iex> delete_vote(vote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vote(current_user, %CloseVote{} = vote) do
    System.audited("destroy", current_user, fn ->
      Repo.delete(vote)
    end)
    |> MessageCaching.update_cached_message()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vote changes.

  ## Examples

      iex> change_vote(vote)
      %Ecto.Changeset{source: %CloseVote{}}

  """
  def new_change_vote(%CloseVote{} = vote) do
    CloseVote.new_changeset(vote, %{})
  end

  @doc """
  Creates a vote for a close vote.

  ## Examples

      iex> vote(%User{}, %CloseVote{})
      {:ok, %CloseVoteVoter{}}
  """
  def vote(user, %CloseVote{} = vote) do
    settings = Cforum.Accounts.Settings.get_global_setting() || %Cforum.Accounts.Setting{}

    ret =
      %CloseVoteVoter{}
      |> CloseVoteVoter.changeset(%{user_id: user.user_id, close_vote_id: vote.close_vote_id})
      |> Repo.insert()

    # ensure that voters have been loaded
    vote = Repo.preload(vote, [:voters])

    maybe_apply_vote_action(
      ret,
      vote,
      length(vote.voters) + 1,
      Cforum.ConfigManager.conf(settings, "close_vote_votes", :int),
      Cforum.ConfigManager.conf(settings, "close_vote_action_" <> vote.reason)
    )

    MessageCaching.update_cached_message(vote)

    ret
  end

  defp maybe_apply_vote_action({:ok, _}, vote, no_votes, votes_wanted, action) when no_votes >= votes_wanted do
    System.audited("finished", nil, fn ->
      vote
      |> CloseVote.finish_changeset()
      |> Repo.update()
      |> case do
        {:ok, _} = ret ->
          apply_vote_action(vote, action)
          ret

        err ->
          err
      end
    end)
  end

  defp maybe_apply_vote_action(_, _, _, _, _), do: nil

  defp apply_vote_action(%CloseVote{vote_type: true} = vote, _) do
    m = Messages.get_message!(vote.message_id, view_all: true)

    thread =
      m.thread_id
      |> Threads.get_thread!()
      |> Threads.build_message_tree("ascending")

    message = Messages.get_message_from_mid!(thread, m.message_id)

    with {:ok, _} <- Messages.unflag_no_answer(nil, message, "no-answer"),
         {:ok, _} <- Messages.restore_message(nil, message),
         do: {:ok, message}

    ThreadCaching.refresh_cached_thread(thread)
  end

  defp apply_vote_action(vote, "close") do
    m = Messages.get_message!(vote.message_id, view_all: true)

    thread =
      m.thread_id
      |> Threads.get_thread!()
      |> Threads.build_message_tree("ascending")

    message = Messages.get_message_from_mid!(thread, m.message_id)

    Messages.flag_no_answer(nil, message, "no-answer")

    ThreadCaching.refresh_cached_thread(thread)
  end

  defp apply_vote_action(vote, "hide") do
    m = Messages.get_message!(vote.message_id, view_all: true)

    thread =
      m.thread_id
      |> Threads.get_thread!()
      |> Threads.build_message_tree("ascending")

    message = Messages.get_message_from_mid!(thread, m.message_id)

    Messages.delete_message(nil, message)

    ThreadCaching.refresh_cached_thread(thread)
  end

  @doc """
  Deletes a vote for a close vote.

  ## Examples

      iex> take_back_vote(%User{}, %CloseVote{})
      {:ok, %CloseVoteVoter{}}
  """
  def take_back_vote(user, %CloseVote{} = vote) do
    voter = Repo.get_by!(CloseVoteVoter, user_id: user.user_id, close_vote_id: vote.close_vote_id)
    Repo.delete(voter)
    MessageCaching.update_cached_message(vote)
  end

  @doc """
  Returns the reopen vote for the given `message` or `nil` if not
  present

  ## Examples

      iex> get_close_vote(%Message{})
      %CloseVote{vote_type: false}
  """
  def get_close_vote(message), do: get_vote_by_type(message, "close")

  @doc """
  Returns the reopen vote for the given `message` or `nil` if not
  present

  ## Examples

      iex> get_reopen_vote(%Message{})
      %CloseVote{vote_type: true}
  """
  def get_reopen_vote(message), do: get_vote_by_type(message, "reopen")

  @doc """
  Returns the close or reopen vote for the given `message` or `nil` if
  not present

  ## Examples

      iex> get_vote_by_type(%Message{}, "close")
      %CloseVote{vote_type: false}

      iex> get_vote_by_type(%Message{}, "open")
      %CloseVote{vote_type: true}
  """
  def get_vote_by_type(message, type)
  def get_vote_by_type(message, "close"), do: get_vote_by_type(message, false)
  def get_vote_by_type(message, "reopen"), do: get_vote_by_type(message, true)

  def get_vote_by_type(message, type) do
    message = Repo.preload(message, [:close_votes])
    Enum.find(message.close_votes, &(&1.vote_type == type))
  end

  @doc """
  Returns the first unfinished vote for the given `message` or `nil`
  if not present

  ## Examples

      iex> get_unfinished_vote(%Message{})
      %CloseVote{}
  """
  def get_unfinished_vote(message) do
    message = Repo.preload(message, [:close_votes])
    Enum.find(message.close_votes, &(&1.finished == false))
  end

  @doc """
  Returns the number of votes for a close/reopen vote

  ## Examples

      iex> no_votes(%CloseVote{})
      1
  """
  def no_votes(vote) do
    vote = Repo.preload(vote, [:voters])
    length(vote.voters)
  end

  @doc """
  Returns `true` if the `user` has voted for a close/reopen vote. If
  the second argument is a message, it looks for the first unfinished
  vote.

  ## Examples

      iex> has_voted?(%User{}, %Message{})
      true
  """
  def has_voted?(user, vote_or_message)
  def has_voted?(user, %Message{} = message), do: has_voted?(user, get_unfinished_vote(message))

  def has_voted?(user, %CloseVote{} = vote) do
    vote = Repo.preload(vote, [:voters])
    Enum.find(vote.voters, &(&1.user_id == user.user_id)) != nil
  end

  @doc """
  Returns the list of voters for a vote

  ## Examples:

      iex> list_voters(%CloseVote{})
      [%CloseVoteVoter{}, ...]
  """
  def list_voters(%CloseVote{} = vote) do
    from(cvv in CloseVoteVoter, where: cvv.close_vote_id == ^vote.close_vote_id)
    |> Repo.all()
  end
end
