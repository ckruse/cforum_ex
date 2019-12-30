defmodule Cforum.Constants do
  defmacro __using__(_) do
    quote do
      @permission_moderate "moderate"
      @permission_write "write"
      @permission_read "read"

      @permission_known_write "known-write"
      @permission_known_read "known-read"

      @permissions [@permission_moderate, @permission_write, @permission_read]

      @badge_upvote "upvote"
      @badge_downvote "downvote"
      @badge_retag "retag"
      @badge_create_tags "create_tag"
      @badge_create_tag_synonym "create_tag_synonym"
      @badge_edit_question "edit_question"
      @badge_edit_answer "edit_answer"
      @badge_moderator_tools "moderator_tools"
      @badge_seo_profi "seo_profi"

      @badge_types [
        @badge_upvote,
        @badge_downvote,
        @badge_retag,
        @badge_create_tags,
        @badge_create_tag_synonym,
        @badge_edit_question,
        @badge_edit_answer,
        @badge_moderator_tools,
        @badge_seo_profi,
        "custom"
      ]

      @badge_medal_types ~w[bronze silver gold]
    end
  end
end
