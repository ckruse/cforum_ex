defmodule Cforum.TagTest do
  use Cforum.ModelCase

  alias Cforum.Forums.Threads.Tag

  @valid_attrs %{num_messages: 42, slug: "some content", suggest: true, tag_name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Tag.changeset(%Tag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Tag.changeset(%Tag{}, @invalid_attrs)
    refute changeset.valid?
  end
end
