defmodule Cforum.Messages.CloseVotesTest do
  use Cforum.DataCase

  alias Cforum.Messages
  alias Cforum.Messages.CloseVotes
  alias Cforum.Messages.{CloseVote, CloseVoteVoter}

  setup do
    forum = insert(:forum)
    thread = insert(:thread)
    message = insert(:message, thread: thread, forum: forum)
    user = insert(:user)

    {:ok, message: message, thread: thread, forum: forum, user: user}
  end

  test "list_close_votes/1 returns all close and reopen votes for a message", %{message: message} do
    vote = insert(:close_vote, message: message)
    assert CloseVotes.list_votes(message) == [unload_relations(vote, [:message])]
  end

  test "get_vote!/1 returns the close_vote with given id", %{message: message} do
    vote = insert(:close_vote, message: message)
    assert CloseVotes.get_vote!(vote.close_vote_id) == unload_relations(vote, [:message])
  end

  test "create_vote/3 with valid data creates a close_vote", %{message: message, user: user} do
    params = params_for(:close_vote, message: nil)
    assert {:ok, %CloseVote{} = vote} = CloseVotes.create_vote(user, message, params)
    assert vote.reason == params[:reason]
    assert vote.finished == false
    assert vote.message_id == message.message_id
    assert vote.vote_type == false
  end

  test "create_vote/3 votes for the new close vote", %{user: user, message: message} do
    params = params_for(:close_vote, message: nil)
    assert {:ok, %CloseVote{} = vote} = CloseVotes.create_vote(user, message, params)
    assert length(vote.voters) == 1
  end

  test "create_vote/3 with invalid data returns error changeset", %{user: user, message: message} do
    assert {:error, %Ecto.Changeset{}} = CloseVotes.create_vote(user, message, %{})
  end

  test "create_reopen_vote/3 with valid data creates a reopen vote", %{message: message, user: user} do
    params = params_for(:close_vote, message: nil, custom_reason: "foobar")
    assert {:ok, %CloseVote{} = vote} = CloseVotes.create_reopen_vote(user, message, params)
    assert vote.reason == "custom"
    assert vote.custom_reason == "foobar"
    assert vote.finished == false
    assert vote.message_id == message.message_id
    assert vote.vote_type == true
  end

  test "update_vote/3 with valid data updates the vote", %{message: message, user: user} do
    vote = insert(:close_vote, message: message)
    assert {:ok, vote} = CloseVotes.update_vote(user, vote, %{reason: "illegal"})
    assert %CloseVote{} = vote
    assert vote.reason == "illegal"
    assert vote.finished == false
    assert vote.message_id == message.message_id
    assert vote.vote_type == false
  end

  test "create_reopen_vote/3 with invalid data returns error changeset", %{user: user, message: message} do
    assert {:error, %Ecto.Changeset{}} = CloseVotes.create_reopen_vote(user, message, %{})
  end

  test "update_vote/3 with invalid data returns error changeset", %{message: message, user: user} do
    vote = insert(:close_vote, message: message)
    assert {:error, %Ecto.Changeset{}} = CloseVotes.update_vote(user, vote, %{reason: nil})
    assert unload_relations(vote, [:message]) == CloseVotes.get_vote!(vote.close_vote_id)
  end

  test "delete_vote/1 deletes the vote", %{message: message, user: user} do
    vote = insert(:close_vote, message: message)
    assert {:ok, %CloseVote{}} = CloseVotes.delete_vote(user, vote)
    assert_raise Ecto.NoResultsError, fn -> CloseVotes.get_vote!(vote.close_vote_id) end
  end

  test "new_change_vote/1 returns a vote changeset", %{message: message} do
    vote = insert(:close_vote, message: message)
    assert %Ecto.Changeset{} = CloseVotes.new_change_vote(vote)
  end

  test "vote/2 votes for a close vote", %{message: message, user: user} do
    vote = insert(:close_vote, message: message)
    assert {:ok, %CloseVoteVoter{} = voter} = CloseVotes.vote(user, vote)
    assert voter.user_id == user.user_id
  end

  test "vote/2 applies the vote action `delete` when all votes have been cast", %{message: message, user: user} do
    insert(:setting, options: %{"close_vote_votes" => 1, "close_vote_action_spam" => "hide"})
    vote = insert(:close_vote, message: message, reason: "spam")
    assert {:ok, %CloseVoteVoter{} = voter} = CloseVotes.vote(user, vote)
    message = Messages.get_message!(message.message_id, view_all: true)
    assert message.deleted == true
  end

  test "vote/2 applies the vote action `close` when all votes have been cast", %{message: message, user: user} do
    insert(:setting, options: %{"close_vote_votes" => 1, "close_vote_action_spam" => "close"})
    vote = insert(:close_vote, message: message, reason: "spam")
    assert {:ok, %CloseVoteVoter{} = voter} = CloseVotes.vote(user, vote)
    message = Messages.get_message!(message.message_id, view_all: true)
    assert message.deleted == false
    assert message.flags["no-answer"] == "yes"
  end

  test "take_back_vote/2 removes a vote", %{message: message, user: user} do
    vote = insert(:close_vote, message: message)
    CloseVotes.vote(user, vote)
    assert {:ok, %CloseVoteVoter{} = voter} = CloseVotes.take_back_vote(user, vote)
    assert_raise Ecto.NoResultsError, fn -> Cforum.Repo.get!(CloseVoteVoter, voter.close_votes_voter_id) end
  end

  test "get_close_vote/1 returns the close vote for a message", %{message: message} do
    vote = insert(:close_vote, message: message)
    insert(:close_vote, message: message, vote_type: true)
    assert CloseVotes.get_close_vote(message) == unload_relations(vote, [:message])
  end

  test "get_close_vote/1 returns nil if a message has no close vote", %{message: message} do
    insert(:close_vote, message: message, vote_type: true)
    assert CloseVotes.get_close_vote(message) == nil
  end

  test "get_reopen_vote/1 returns the reopen vote for a message", %{message: message} do
    insert(:close_vote, message: message)
    vote = insert(:close_vote, message: message, vote_type: true)
    assert CloseVotes.get_reopen_vote(message) == unload_relations(vote, [:message])
  end

  test "get_reopen_vote/1 returns nil if a message has no reopen vote", %{message: message} do
    insert(:close_vote, message: message)
    assert CloseVotes.get_reopen_vote(message) == nil
  end

  test "get_vote_by_type/2 returns the vote of the specified type", %{message: message} do
    close_vote = insert(:close_vote, message: message)
    reopen_vote = insert(:close_vote, message: message, vote_type: true)

    assert CloseVotes.get_vote_by_type(message, "reopen") == unload_relations(reopen_vote, [:message])
    assert CloseVotes.get_vote_by_type(message, "close") == unload_relations(close_vote, [:message])
    assert CloseVotes.get_vote_by_type(message, true) == unload_relations(reopen_vote, [:message])
    assert CloseVotes.get_vote_by_type(message, false) == unload_relations(close_vote, [:message])
  end

  test "get_unfinished_vote/1 returns the first unfinished vote", %{message: message} do
    close_vote = insert(:close_vote, message: message)
    insert(:close_vote, message: message, vote_type: true)
    assert CloseVotes.get_unfinished_vote(message) == unload_relations(close_vote, [:message])
  end

  test "no_votes/1 returns the number of votes", %{message: message, user: user} do
    vote = insert(:close_vote, message: message)
    assert CloseVotes.no_votes(vote) == 0
    CloseVotes.vote(user, vote)
    assert CloseVotes.no_votes(vote) == 1
  end

  test "has_voted?/2 returns true if a user has voted for a close/reopen vote", %{message: message, user: user} do
    vote = insert(:close_vote, message: message)
    CloseVotes.vote(user, vote)
    assert CloseVotes.has_voted?(user, vote) == true
  end

  test "has_voted?/2 returns false if a user hasn't voted for a close/reopen vote", %{message: message, user: user} do
    vote = insert(:close_vote, message: message)
    assert CloseVotes.has_voted?(user, vote) == false
  end
end
