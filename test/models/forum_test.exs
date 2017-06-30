defmodule Cforum.ForumTest do
  use Cforum.ModelCase

  alias Cforum.Forums.Forum

  @valid_attrs %{description: "some content", keywords: "some content", name: "some content", position: 42, short_name: "some content", slug: "some content", standard_permission: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Forum.changeset(%Forum{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Forum.changeset(%Forum{}, @invalid_attrs)
    refute changeset.valid?
  end
end
