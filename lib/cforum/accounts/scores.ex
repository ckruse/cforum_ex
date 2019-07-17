defmodule Cforum.Accounts.Scores do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Accounts.Score
  alias Cforum.Accounts.User
  alias Cforum.Caching

  @doc """
  Returns the list of scores.

  ## Examples

      iex> list_scores()
      [%Score{}, ...]

  """
  def list_scores(user) do
    from(score in Score, where: score.user_id == ^user.user_id)
    |> Repo.all()
  end

  @doc """
  Gets a single score.

  Raises `Ecto.NoResultsError` if the Score does not exist.

  ## Examples

      iex> get_score!(123)
      %Score{}

      iex> get_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_score!(id), do: Repo.get!(Score, id)

  @doc """
  Creates a score.

  ## Examples

      iex> create_score(%{field: value})
      {:ok, %Score{}}

      iex> create_score(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_score(attrs \\ %{}) do
    %Score{}
    |> Score.changeset(attrs)
    |> Repo.insert()
    |> notify_user(:create)
  end

  @doc """
  Deletes a Score.

  ## Examples

      iex> delete_score(score)
      {:ok, %Score{}}

      iex> delete_score(score)
      {:error, %Ecto.Changeset{}}

  """
  def delete_score(%Score{} = score) do
    score
    |> Repo.delete()
    |> notify_user(:delete)
  end

  def delete_scores_by_vote_id(vote_id) do
    scores = from(score in Score, where: score.vote_id == ^vote_id) |> Repo.all()
    Enum.each(scores, &delete_score/1)
    :ok
  end

  def delete_score_by_message_id_and_user_id(message_id, user_id) do
    score =
      from(score in Score, where: score.message_id == ^message_id and score.user_id == ^user_id)
      |> Repo.one()

    case score do
      nil ->
        nil

      score ->
        score
        |> Repo.delete()
        |> notify_user(:delete)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking score changes.

  ## Examples

      iex> change_score(score)
      %Ecto.Changeset{source: %Score{}}

  """
  def change_score(%Score{} = score) do
    Score.changeset(score, %{})
  end

  def notify_user({:ok, score}, action) do
    notify_user(score, action)
    {:ok, score}
  end

  def notify_user(%Score{} = score, action) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      Caching.update(:cforum, "users/#{score.user_id}", fn user ->
        if action == :delete,
          do: %User{user | score: user.score - score.value},
          else: %User{user | score: user.score + score.value}
      end)

      user = Cforum.Accounts.Users.get_user!(score.user_id)
      CforumWeb.Endpoint.broadcast!("users:#{user.user_id}", "score-update", %{value: score.value, score: user.score})
    end)

    score
  end

  def notify_user(retval, _), do: retval
end
