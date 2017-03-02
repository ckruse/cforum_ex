defmodule Cforum.ThreadTest do
  use Cforum.ModelCase

  alias Cforum.Thread

  @valid_attrs %{archived: true, deleted: true, flags: %{}, latest_message: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, sticky: true, tid: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Thread.changeset(%Thread{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Thread.changeset(%Thread{}, @invalid_attrs)
    refute changeset.valid?
  end
end
