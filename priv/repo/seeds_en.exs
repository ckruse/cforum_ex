# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Cforum.Repo.insert!(%Cforum.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Cforum.Accounts.Badges

Badges.create_badge(nil, %{
  score_needed: 50,
  name: "Upvote",
  slug: "upvote",
  badge_type: "upvote",
  badge_medal_type: "bronze",
  description: "The user gains the right to upvote a message."
})

Badges.create_badge(nil, %{
  score_needed: 200,
  name: "Downvote",
  slug: "downvote",
  badge_type: "downvote",
  badge_medal_type: "bronze",
  description: "The user gains the right to downvote a message."
})

Badges.create_badge(nil, %{
  score_needed: 500,
  name: "Retag",
  slug: "retag",
  badge_type: "retag",
  badge_medal_type: "bronze",
  description: "The user gains the right to retag a message."
})

Badges.create_badge(nil, %{
  score_needed: 1200,
  name: "Create tag",
  slug: "create_tag",
  badge_type: "create_tag",
  badge_medal_type: "silver",
  description: "The user gains the right to create new tags"
})

Badges.create_badge(nil, %{
  score_needed: 1500,
  name: "Create tag synonym",
  slug: "create_tag_synonym",
  badge_type: "create_tag_synonym",
  badge_medal_type: "silver",
  description: "The user gains the right to create tag synonyms"
})

Badges.create_badge(nil, %{
  score_needed: 2000,
  name: "Edit question",
  slug: "edit_question",
  badge_type: "edit_question",
  badge_medal_type: "silver",
  description: "The user gains the right to edit questions"
})

Badges.create_badge(nil, %{
  score_needed: 2500,
  name: "Edit answer",
  slug: "edit_answer",
  badge_type: "edit_answer",
  badge_medal_type: "silver",
  description: "The user gains the right to edit questions"
})

Badges.create_badge(nil, %{
  score_needed: 5000,
  name: "Moderator tools",
  slug: "moderator_tools",
  badge_type: "moderator_tools",
  badge_medal_type: "gold",
  description: "The user gains access to the moderator tools"
})

Badges.create_badge(nil, %{
  name: "Yearling",
  slug: "yearling",
  description: "The user is registered one year",
  badge_type: "custom",
  badge_medal_type: "bronze"
})

Badges.create_badge(nil, %{
  name: "Autobiographer",
  slug: "autobiographer",
  description:
    "The user has saved a description, a homepage and either an email address, a twitter handle, a homepage URL or a jabber ID",
  badge_type: "custom",
  badge_medal_type: "bronze"
})

Badges.create_badge(nil, %{
  score_needed: 700,
  name: "SEO profi",
  slug: "seo_profi",
  badge_type: "seo_profi",
  badge_medal_type: "bronze",
  description: "The user may allow search engines to follow their homepage link"
})

Badges.create_badge(nil, %{
  name: "Voter",
  slug: "voter",
  description: "The user has voted for 100, 250, 100, 2500, 5000 or 10000 messages",
  badge_type: "custom",
  badge_medal_type: "bronze"
})

Badges.create_badge(nil, %{
  name: "Chisel",
  slug: "chisel",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "The user created 100 messages"
})

Badges.create_badge(nil, %{
  messages: 1000,
  name: "Brush",
  slug: "brush",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "The user created 1000 messages"
})

Badges.create_badge(nil, %{
  name: "Quill",
  slug: "quill",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "The user created 2500 messages"
})

Badges.create_badge(nil, %{
  name: "Pen",
  slug: "pen",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "The user created 5000 messages"
})

Badges.create_badge(nil, %{
  name: "Printing press",
  slug: "printing_press",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "The user created 7500 messages"
})

Badges.create_badge(nil, %{
  name: "Typewriter",
  slug: "typewriter",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "The user created 10000 messages"
})

Badges.create_badge(nil, %{
  name: "Matrix printer",
  slug: "matrix_printer",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "The user created 20000 messages"
})

Badges.create_badge(nil, %{
  name: "Inkjet printer",
  slug: "inkjet_printer",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "The user created 30000 messages"
})

Badges.create_badge(nil, %{
  name: "Laser printer",
  slug: "laser_printer",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "The user created 40000 messages"
})

Badges.create_badge(nil, %{
  name: "1000 monkeys",
  slug: "1000_monkeys",
  badge_type: "custom",
  badge_medal_type: "gold",
  description: "The user created 50000 messages"
})

Badges.create_badge(nil, %{
  name: "Donee",
  slug: "donee",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "A message of this user has been upvoted at least once"
})

Badges.create_badge(nil, %{
  name: "Nice answer",
  slug: "nice_answer",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "A message of this user has been upvoted at least five times"
})

Badges.create_badge(nil, %{
  name: "Good answer",
  slug: "good_answer",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "A message of this user has been upvoted at least 10 times"
})

Badges.create_badge(nil, %{
  name: "Great answer",
  slug: "great_answer",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "A message of this user has been upvoted at least 15 times"
})

Badges.create_badge(nil, %{
  name: "Superb answer",
  slug: "superb_answer",
  badge_type: "custom",
  badge_medal_type: "gold",
  description: "A message of this user has been upvoted at least 20 times"
})

Badges.create_badge(nil, %{
  name: "Controverse",
  slug: "controverse",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "A message of this user has been upvoted at least five times and downvoted at least five times"
})

Badges.create_badge(nil, %{
  name: "Enthusiast",
  slug: "enthusiast",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "The user has upvoted at least one message"
})

Badges.create_badge(nil, %{
  name: "Critic",
  slug: "critic",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "The user has downvoted at least one message"
})

Badges.create_badge(nil, %{
  name: "Teacher",
  slug: "teacher",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "The user has written an answer to a messages which has been upvoted at least once"
})
