defmodule Cforum.TagFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Forums.{Tag, TagSynonym}

      def tag_factory do
        %Tag{
          tag_name: sequence("Tag "),
          slug: sequence("tag-"),
          forum: build(:public_forum),
          suggest: true
        }
      end

      def tag_synonym_factory do
        %TagSynonym{
          tag: build(:tag),
          synonym: sequence("Tag Synonym "),
          forum: build(:forum)
        }
      end
    end
  end
end
