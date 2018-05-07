defmodule Cforum.Forums.TagsTest do
  use Cforum.DataCase

  alias Cforum.Forums.{Tags, Tag, TagSynonym, Messages}

  describe "tags" do
    test "list_tags/2 lists all tags for one forum" do
      forum = insert(:public_forum)
      tags = insert_list(3, :tag, forum: forum) |> Enum.sort(&(&1.tag_name <= &2.tag_name))

      found = Tags.list_tags(forum)
      assert length(found) == 3
      assert Enum.map(tags, & &1.tag_id) == Enum.map(found, & &1.tag_id)
    end

    test "list_tags/2 lists all tags for all accessible forums" do
      forum = insert(:public_forum)
      forum1 = insert(:public_forum)

      tags =
        (insert_list(3, :tag, forum: forum) ++ insert_list(3, :tag, forum: forum1))
        |> Enum.sort(&(&1.tag_name <= &2.tag_name))

      found = Tags.list_tags(nil, [forum, forum1])
      assert length(found) == 6
      assert Enum.map(tags, & &1.tag_id) == Enum.map(found, & &1.tag_id)
    end

    test "list_tags/2 doesn't list tags from forums not accessible" do
      forum = insert(:public_forum)
      forum1 = insert(:public_forum)
      tags = insert_list(3, :tag, forum: forum) |> Enum.sort(&(&1.tag_name <= &2.tag_name))

      insert_list(3, :tag, forum: forum1)

      found = Tags.list_tags(nil, [forum])
      assert length(found) == 3
      assert Enum.map(tags, & &1.tag_id) == Enum.map(found, & &1.tag_id)
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = insert(:tag)
      assert Tags.get_tag!(tag.tag_id).tag_id == tag.tag_id
    end

    test "get_tags/2 returns a list of existing tags ordered by name" do
      forum = insert(:public_forum)

      tags =
        (insert_list(3, :tag, forum: forum) ++ [insert(:tag, tag_name: "000 foo", forum: forum)])
        |> Enum.sort(&(String.downcase(&2.tag_name) <= String.downcase(&1.tag_name)))

      tag_names =
        (Enum.map(tags, & &1.tag_name) ++ ["foo", "bar"])
        |> Enum.sort(&(String.downcase(&1) <= String.downcase(&2)))

      tags_list = Tags.get_tags(forum, tag_names)

      assert length(tags_list) == length(tags)
      assert Enum.map(tags_list, & &1.tag_name) == Enum.map(tags, & &1.tag_name)
    end

    test "create_tag/2 with valid data creates a tag" do
      forum = insert(:forum)
      attrs = params_for(:tag)
      assert {:ok, %Tag{} = tag} = Tags.create_tag(forum, attrs)
      assert tag.tag_name == attrs[:tag_name]
      assert tag.slug == attrs[:slug]
      assert tag.suggest == attrs[:suggest]
    end

    test "create_tag/2 with invalid data returns error changeset" do
      forum = insert(:forum)
      assert {:error, %Ecto.Changeset{}} = Tags.create_tag(forum, %{})
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = insert(:tag, suggest: false)
      assert {:ok, tag} = Tags.update_tag(tag, %{suggest: true})
      assert %Tag{} = tag
      assert tag.suggest == true
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = insert(:tag)
      assert {:error, %Ecto.Changeset{}} = Tags.update_tag(tag, %{tag_name: ""})

      tag1 = Tags.get_tag!(tag.tag_id)

      assert tag.tag_name == tag1.tag_name
      assert tag.slug == tag1.slug
      assert tag.suggest == tag1.suggest
    end

    test "merge_tag/2" do
      forum = insert(:forum)
      tag = insert(:tag, forum: forum)
      new_tag = insert(:tag, forum: forum)

      thread = insert(:thread, forum: forum)
      message = insert(:message, thread: thread, forum: forum, tags: [tag])

      assert {:ok, %Tag{} = new_tag} = Tags.merge_tag(tag, new_tag)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_tag!(tag.tag_id) end
      [new_message] = Messages.list_messages_for_tag(forum, new_tag)

      assert message.message_id == new_message.message_id
      assert List.first(new_tag.synonyms).synonym == tag.tag_name
    end

    test "delete_tag/1 deletes the tag" do
      tag = insert(:tag)
      assert {:ok, %Tag{}} = Tags.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_tag!(tag.tag_id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = insert(:tag)
      assert %Ecto.Changeset{} = Tags.change_tag(tag)
    end
  end

  describe "synonyms" do
    test "get_tag_synonym!/2 returns the tag synonym with given id" do
      forum = insert(:forum)
      tag = insert(:tag, forum: forum)
      synonym = insert(:tag_synonym, tag: tag, forum: forum)
      assert Tags.get_tag_synonym!(synonym.tag, synonym.tag_synonym_id).tag_synonym_id == synonym.tag_synonym_id
    end

    test "create_tag_synonym/2 with valid data creates a tag synonym" do
      forum = insert(:forum)
      tag = insert(:tag, forum: forum)
      attrs = params_for(:tag_synonym)
      assert {:ok, %TagSynonym{} = tag} = Tags.create_tag_synonym(tag, attrs)
      assert tag.synonym == attrs[:synonym]
      assert tag.tag_id == tag.tag_id
      assert tag.forum_id == forum.forum_id
    end

    test "create_tag_synonym/2 with invalid data returns error changeset" do
      forum = insert(:forum)
      tag = insert(:tag, forum: forum)
      assert {:error, %Ecto.Changeset{}} = Tags.create_tag(tag, %{})
    end

    test "update_tag_synonym/2 with valid data updates the tag synonym" do
      forum = insert(:forum)
      tag = insert(:tag, forum: forum)
      synonym = insert(:tag_synonym, tag: tag, forum: forum)
      assert {:ok, tag_synonym} = Tags.update_tag_synonym(tag, synonym, %{synonym: "foo"})
      assert %TagSynonym{} = tag_synonym

      assert tag_synonym.synonym == "foo"
      assert tag_synonym.tag_id == synonym.tag_id
      assert tag_synonym.forum_id == synonym.forum_id
    end

    test "update_tag_synonym/2 with invalid data returns error changeset" do
      forum = insert(:forum)
      tag = insert(:tag, forum: forum)
      synonym = insert(:tag_synonym, tag: tag, forum: forum)

      assert {:error, %Ecto.Changeset{}} = Tags.update_tag_synonym(tag, synonym, %{synonym: ""})

      tag_synonym = Tags.get_tag_synonym!(tag, synonym.tag_synonym_id)

      assert tag_synonym.synonym == synonym.synonym
      assert tag_synonym.tag_id == synonym.tag_id
      assert tag_synonym.forum_id == synonym.forum_id
    end

    test "delete_tag_synonym/1 deletes the tag synonym" do
      forum = insert(:forum)
      tag = insert(:tag, forum: forum)
      synonym = insert(:tag_synonym, tag: tag, forum: forum)

      assert {:ok, %TagSynonym{}} = Tags.delete_tag_synonym(synonym)
      assert_raise Ecto.NoResultsError, fn -> Tags.get_tag_synonym!(tag, synonym.tag_synonym_id) end
    end

    test "change_tag_synonym/2 returns a tag synonym changeset" do
      forum = insert(:forum)
      tag = insert(:tag, forum: forum)
      synonym = insert(:tag_synonym, tag: tag, forum: forum)

      assert %Ecto.Changeset{} = Tags.change_tag_synonym(tag, synonym)
    end
  end
end
