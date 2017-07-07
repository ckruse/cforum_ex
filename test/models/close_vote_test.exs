defmodule Cforum.CloseVoteTest do
  use Cforum.ModelCase

  alias Cforum.Forums.CloseVote

  @valid_attrs %{custom_reason: "some content", duplicate_slug: "some content", finished: true, reason: "some content", vote_type: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = CloseVote.changeset(%CloseVote{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = CloseVote.changeset(%CloseVote{}, @invalid_attrs)
    refute changeset.valid?
  end
end
