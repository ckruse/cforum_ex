defmodule Cforum.MediaTest do
  use Cforum.DataCase

  alias Cforum.Media
  alias Cforum.Media.Image

  describe "media" do
    test "list_images/0 returns all media" do
      image = insert(:image)
      assert Media.list_images() |> Enum.map(& &1.medium_id) == [image.medium_id]
    end

    test "get_image!/1 returns the image with given id" do
      image = insert(:image)
      assert Media.get_image!(image.medium_id).medium_id == image.medium_id
    end

    test "create_image/1 with valid data creates an image" do
      upload = %Plug.Upload{path: "test/fixtures/image.png", filename: "image.png", content_type: "image/png"}
      assert {:ok, %Image{} = image} = Media.create_image(nil, upload)
      assert image.content_type == "image/png"
      assert image.filename
      assert image.orig_name == "image.png"
    end

    test "create_image/1 with an upper case extension creates an image" do
      upload = %Plug.Upload{path: "test/fixtures/image.png", filename: "image.PNG", content_type: "image/png"}
      assert {:ok, %Image{} = image} = Media.create_image(nil, upload)
      assert image.content_type == "image/png"
      assert image.filename
      assert image.orig_name == "image.PNG"
    end

    test "create_image/1 with an mixed case extension creates an image" do
      upload = %Plug.Upload{path: "test/fixtures/image.png", filename: "image.PNg", content_type: "image/png"}
      assert {:ok, %Image{} = image} = Media.create_image(nil, upload)
      assert image.content_type == "image/png"
      assert image.filename
      assert image.orig_name == "image.PNg"
    end

    test "delete_image/1 deletes the image" do
      user = insert(:user)
      image = insert(:image)
      assert {:ok, %Image{}} = Media.delete_image(image, user)
      assert_raise Ecto.NoResultsError, fn -> Media.get_image!(image.medium_id) end
    end
  end
end
