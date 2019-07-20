defmodule Cforum.Accounts.ScoresTest do
  use Cforum.DataCase

  alias Cforum.Accounts.Scores
  alias Cforum.Accounts.Score

  test "list_scores/2 returns all scores" do
    score = insert(:score)
    scores = Scores.list_scores(score.user)
    assert length(scores) == 1
    assert [%Score{}] = scores
    assert Enum.map(scores, & &1.score_id) == [score.score_id]
  end

  test "get_score!/1 returns the score with given id" do
    score = insert(:score)
    score1 = Scores.get_score!(score.score_id)
    assert %Score{} = score1
    assert score1.score_id == score.score_id
  end

  test "create_score/1 with valid data creates a score" do
    user = insert(:user)
    params = params_for(:score, user_id: user.user_id)
    assert {:ok, %Score{} = score} = Scores.create_score(params)
    assert score.user_id == params[:user_id]
    assert score.value == params[:value]
  end

  test "create_score/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Scores.create_score(%{})
  end

  test "delete_score/1 deletes the score" do
    score = insert(:score)
    assert {:ok, %Score{}} = Scores.delete_score(score)
    assert_raise Ecto.NoResultsError, fn -> Scores.get_score!(score.score_id) end
  end

  test "change_score/1 returns a score changeset" do
    score = insert(:score)
    assert %Ecto.Changeset{} = Scores.change_score(score)
  end
end
