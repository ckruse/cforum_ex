defmodule Cforum.MessageTest do
  use Cforum.ModelCase

  alias Cforum.Message

  @valid_attrs %{author: "some content", content: "some content", deleted: true, downvotes: 42, edit_author: "some content", email: "some content", flags: %{}, format: "some content", homepage: "some content", mid: 42, problematic_site: "some content", subject: "some content", up: "some content", upvotes: 42, uuid: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Message.changeset(%Message{}, @invalid_attrs)
    refute changeset.valid?
  end
end
