defmodule Cforum.Forums.Threads.VoteTest do
  use Cforum.ModelCase

  alias Cforum.Forums.Threads.Vote

  @valid_attrs %{vtype: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Vote.changeset(%Vote{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Vote.changeset(%Vote{}, @invalid_attrs)
    refute changeset.valid?
  end
end
