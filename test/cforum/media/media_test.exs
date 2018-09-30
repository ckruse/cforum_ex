defmodule Cforum.MediaTest do
  use Cforum.DataCase

  alias Cforum.Media

  describe "media" do
    alias Cforum.Media.Image

    @valid_attrs %{content_type: "some content_type", filename: "some filename", orig_name: "some orig_name"}
    @update_attrs %{
      content_type: "some updated content_type",
      filename: "some updated filename",
      orig_name: "some updated orig_name"
    }
    @invalid_attrs %{content_type: nil, filename: nil, orig_name: nil}

    def image_fixture(attrs \\ %{}) do
      {:ok, image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Media.create_image()

      image
    end

    test "list_images/0 returns all media" do
      image = image_fixture()
      assert Media.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Media.get_image!(image.medium_id) == image
    end

    test "create_image/1 with valid data creates a image" do
      assert {:ok, %Image{} = image} = Media.create_image(@valid_attrs)
      assert image.content_type == "some content_type"
      assert image.filename == "some filename"
      assert image.orig_name == "some orig_name"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      assert {:ok, image} = Media.update_image(image, @update_attrs)
      assert %Image{} = image
      assert image.content_type == "some updated content_type"
      assert image.filename == "some updated filename"
      assert image.orig_name == "some updated orig_name"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_image(image, @invalid_attrs)
      assert image == Media.get_image!(image.medium_id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Media.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Media.get_image!(image.medium_id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Media.change_image(image)
    end
  end
end
