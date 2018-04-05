defmodule Cforum.CitesTest do
  use Cforum.DataCase

  alias Cforum.Cites
  alias Cforum.Cites.Cite
  alias Cforum.Cites.Vote

  describe "cites" do
    @invalid_attrs %{archived: nil, author: nil, cite: nil, cite_date: nil, creator: nil, url: nil}

    test "list_cites/1 returns all archived cites" do
      cite = insert(:cite)
      build(:cite) |> archived_cite |> insert

      cites = Cites.list_cites(false)
      assert Enum.map(cites, & &1.cite_id) == [cite.cite_id]
    end

    test "list_cites/1 returns all un-archived cites" do
      insert(:cite)
      cite = build(:cite) |> archived_cite |> insert

      cites = Cites.list_cites(true)
      assert Enum.map(cites, & &1.cite_id) == [cite.cite_id]
    end

    test "list_cites/1 sorts by ID per default" do
      cites = insert_list(3, :cite)
      new_cites = Cites.list_cites(false)
      assert Enum.map(new_cites, & &1.cite_id) == Enum.map(Enum.reverse(cites), & &1.cite_id)
    end

    test "count_cites/1 counts all archived cites" do
      insert(:cite)
      build(:cite) |> archived_cite |> insert

      assert Cites.count_cites(false) == 1
    end

    test "count_cites/1 counts all un-archived cites" do
      insert(:cite)
      build(:cite) |> archived_cite |> insert

      assert Cites.count_cites(true) == 1
    end

    test "get_cite!/1 returns the cite with given id" do
      cite = insert(:cite)
      assert Cites.get_cite!(cite.cite_id).cite_id == cite.cite_id
    end

    test "create_cite/1 with valid data creates a cite" do
      attrs = params_for(:cite)
      assert {:ok, %Cite{} = cite} = Cites.create_cite(attrs)
      assert cite.archived == attrs[:archived]
      assert cite.author == attrs[:author]
      assert cite.user_id == nil
      assert cite.message_id == nil
      assert cite.cite == attrs[:cite]
      assert cite.creator == attrs[:creator]
      assert cite.creator_user_id == nil
      assert cite.url == attrs[:url]
    end

    test "create_cite/1 with a user overwrites creator and sets creator_user" do
      attrs = params_for(:cite)
      user = insert(:user)

      assert {:ok, %Cite{} = cite} = Cites.create_cite(attrs, user)
      assert cite.archived == attrs[:archived]
      assert cite.author == attrs[:author]
      assert cite.user_id == nil
      assert cite.message_id == nil
      assert cite.cite == attrs[:cite]
      assert cite.creator == user.username
      assert cite.creator_user_id == user.user_id
      assert cite.url == attrs[:url]
    end

    test "create_cite/1 with a URL to a message sets message_id, user_id and overwrites author" do
      forum = insert(:public_forum)
      thread = insert(:thread, forum: forum)
      message = insert(:message, thread: thread, forum: forum, tags: [])

      attrs = params_for(:cite, url: "http://localhost:4000/#{forum.slug}#{thread.slug}/#{message.message_id}")

      assert {:ok, %Cite{} = cite} = Cites.create_cite(attrs)
      assert cite.archived == attrs[:archived]
      assert cite.author == message.author
      assert cite.user_id == message.user_id
      assert cite.message_id == message.message_id
      assert cite.cite == attrs[:cite]
      assert cite.creator == attrs[:creator]
      assert cite.creator_user_id == nil
      assert cite.url == attrs[:url]
    end

    test "create_cite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cites.create_cite(@invalid_attrs)
    end

    test "update_cite/2 with valid data updates the cite" do
      cite = insert(:cite)
      assert {:ok, cite} = Cites.update_cite(cite, %{author: "foobar"})
      assert %Cite{} = cite
      assert cite.author == "foobar"
    end

    test "update_cite/2 with invalid data returns error changeset" do
      cite = insert(:cite)
      assert {:error, %Ecto.Changeset{}} = Cites.update_cite(cite, @invalid_attrs)

      cite1 = Cites.get_cite!(cite.cite_id)

      assert cite.archived == cite1.archived
      assert cite.author == cite1.author
      assert cite.user_id == cite1.user_id
      assert cite.message_id == cite1.message_id
      assert cite.cite == cite1.cite
      assert cite.creator == cite1.creator
      assert cite.creator_user_id == cite1.creator_user_id
      assert cite.url == cite1.url
    end

    test "delete_cite/1 deletes the cite" do
      cite = insert(:cite)
      assert {:ok, %Cite{}} = Cites.delete_cite(cite)
      assert_raise Ecto.NoResultsError, fn -> Cites.get_cite!(cite.cite_id) end
    end

    test "change_cite/1 returns a cite changeset" do
      cite = insert(:cite)
      assert %Ecto.Changeset{} = Cites.change_cite(cite)
    end
  end

  describe "voting" do
    test "score/1 returns the calculated score" do
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, vote_type: Vote.upvote())
      insert(:cite_vote, cite: cite, vote_type: Vote.upvote())
      insert(:cite_vote, cite: cite, vote_type: Vote.downvote())

      cite = Cites.get_cite!(cite.cite_id)

      assert Cites.score(cite) == 1
    end

    test "no_votes/1 returns the number of votes" do
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, vote_type: Vote.upvote())
      insert(:cite_vote, cite: cite, vote_type: Vote.upvote())
      insert(:cite_vote, cite: cite, vote_type: Vote.downvote())

      cite = Cites.get_cite!(cite.cite_id)

      assert Cites.no_votes(cite) == 3
    end

    test "score_str/1 returns a dash w/o votes" do
      cite = insert(:cite)
      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.score_str(cite) == "–"
    end

    test "score_str/1 returns a +/-0 w/ zero score" do
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, vote_type: Vote.upvote())
      insert(:cite_vote, cite: cite, vote_type: Vote.downvote())

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.score_str(cite) == "±0"
    end

    test "score_str/1 returns a -<num> w/ negative score" do
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, vote_type: Vote.downvote())

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.score_str(cite) == "−1"
    end

    test "score_str/1 returns a +<num> w/ positive score" do
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, vote_type: Vote.upvote())

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.score_str(cite) == "+1"
    end

    test "voted?/2 returns true when user has voted" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, user: user)

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.voted?(cite, user)
    end

    test "voted?/2 returns false when user hasn't voted" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite)

      cite = Cites.get_cite!(cite.cite_id)
      refute Cites.voted?(cite, user)
    end

    test "voted?/3 returns true when user has voted with type" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, user: user)

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.voted?(cite, user, "up")
    end

    test "voted?/3 returns false when user hasn't voted" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite)

      cite = Cites.get_cite!(cite.cite_id)
      refute Cites.voted?(cite, user, "up")
    end

    test "voted?/3 returns false when user has voted differently" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, user: user)

      cite = Cites.get_cite!(cite.cite_id)
      refute Cites.voted?(cite, user, "down")
      assert Cites.voted?(cite, user, "up")
    end

    test "downvoted?/2 returns true when user has downvoted" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, user: user, vote_type: Vote.downvote())

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.downvoted?(cite, user)
    end

    test "downvoted?/2 returns false when user hasn't downvoted" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, user: user, vote_type: Vote.upvote())

      cite = Cites.get_cite!(cite.cite_id)
      refute Cites.downvoted?(cite, user)
    end

    test "downvoted?/2 returns false when user hasn't voted" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, vote_type: Vote.downvote())

      cite = Cites.get_cite!(cite.cite_id)
      refute Cites.downvoted?(cite, user)
    end

    test "upvoted?/2 returns true when user has upvoted" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, user: user, vote_type: Vote.upvote())

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.upvoted?(cite, user)
    end

    test "upvoted?/2 returns false when user hasn't upvoted" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, user: user, vote_type: Vote.downvote())

      cite = Cites.get_cite!(cite.cite_id)
      refute Cites.upvoted?(cite, user)
    end

    test "upvoted?/2 returns false when user hasn't voted" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, vote_type: Vote.upvote())

      cite = Cites.get_cite!(cite.cite_id)
      refute Cites.upvoted?(cite, user)
    end

    test "take_back_vote/2 removes the vote" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, user: user)

      cite = Cites.get_cite!(cite.cite_id)
      Cites.take_back_vote(cite, user)

      cite = Cites.get_cite!(cite.cite_id)
      assert cite.votes == []
    end

    test "take_back_vote/2 doesn't remove foreign votes" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite)

      cite = Cites.get_cite!(cite.cite_id)
      Cites.take_back_vote(cite, user)

      cite = Cites.get_cite!(cite.cite_id)
      assert length(cite.votes) == 1
    end

    test "vote/3 downvotes a cite" do
      user = insert(:user)
      cite = insert(:cite)

      assert {:ok, %Vote{}} = Cites.vote(cite, user, "down")

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.no_votes(cite) == 1
      assert Cites.downvoted?(cite, user)
    end

    test "vote/3 upvotes for a cite" do
      user = insert(:user)
      cite = insert(:cite)

      assert {:ok, %Vote{}} = Cites.vote(cite, user, "up")

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.no_votes(cite) == 1
      assert Cites.upvoted?(cite, user)
    end

    test "vote/3 fails on duplicate vote" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, user: user)

      assert {:error, %Ecto.Changeset{}} = Cites.vote(cite, user, "up")

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.no_votes(cite) == 1
    end

    test "vote/3 fails on 2nd vote on the same cite" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite, user: user)

      assert {:error, %Ecto.Changeset{}} = Cites.vote(cite, user, "down")

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.no_votes(cite) == 1
    end

    test "vote/3 votes on 1st vote of the user but multiple other votes" do
      user = insert(:user)
      cite = insert(:cite)
      insert(:cite_vote, cite: cite)
      insert(:cite_vote, cite: cite)
      insert(:cite_vote, cite: cite)

      assert {:ok, %Vote{}} = Cites.vote(cite, user, "down")

      cite = Cites.get_cite!(cite.cite_id)
      assert Cites.no_votes(cite) == 4
      assert Cites.downvoted?(cite, user)
    end
  end
end
