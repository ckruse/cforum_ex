defmodule Cforum.MessageTagTest do
  use Cforum.ModelCase

  alias Cforum.Forums.MessageTag

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = MessageTag.changeset(%MessageTag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = MessageTag.changeset(%MessageTag{}, @invalid_attrs)
    refute changeset.valid?
  end
end
