defmodule Cforum.CloseVoteVoterTest do
  use Cforum.ModelCase

  alias Cforum.Forums.Threads.CloseVoteVoter

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = CloseVoteVoter.changeset(%CloseVoteVoter{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = CloseVoteVoter.changeset(%CloseVoteVoter{}, @invalid_attrs)
    refute changeset.valid?
  end
end
