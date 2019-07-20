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
  description: "Der Anwender erhält das Recht, einen Beitrag positiv zu bewerten.",
  order: 1
})

Badges.create_badge(nil, %{
  score_needed: 200,
  name: "Downvote",
  slug: "downvote",
  badge_type: "downvote",
  badge_medal_type: "bronze",
  description: "Der Anwender erhält das Recht, einen Beitrag negativ zu bewerten.",
  order: 2
})

Badges.create_badge(nil, %{
  score_needed: 500,
  name: "Recht Tags neu zu vergeben",
  slug: "retag",
  badge_type: "retag",
  badge_medal_type: "bronze",
  description: "Der Anwender erhält das Recht, die Tags eines Beitrags zu ändern.",
  order: 3
})

Badges.create_badge(nil, %{
  score_needed: 700,
  name: "SEO-Profi",
  slug: "seo_profi",
  badge_type: "seo_profi",
  badge_medal_type: "bronze",
  description: "Der Anwender kann Suchmaschinen erlauben, dem Homepage-Link zu folgen.",
  order: 4
})

Badges.create_badge(nil, %{
  score_needed: 1000,
  name: "Abstimmungsrecht über Sperr- und Entsperr-Abstimmungen",
  slug: "visit_close_reopen",
  badge_type: "visit_close_reopen",
  badge_medal_type: "bronze",
  description: "Der Anwender erhält das Recht, an einer Sperr- oder Entsperr-Abstimmung teilzunehmen.",
  order: 5
})

Badges.create_badge(nil, %{
  score_needed: 1200,
  name: "Recht Tags zu erstellen",
  slug: "create_tag",
  badge_type: "create_tag",
  badge_medal_type: "silver",
  description: "Der Anwender erhält das Recht, neue Tags zu erstellen.",
  order: 6
})

Badges.create_badge(nil, %{
  score_needed: 1500,
  name: "Recht Tag-Synonyme zu erstellen",
  slug: "create_tag_synonym",
  badge_type: "create_tag_synonym",
  badge_medal_type: "silver",
  description: "Der Anwender erhält das Recht, Tag-Synonyme zu erstellen.",
  order: 7
})

Badges.create_badge(nil, %{
  score_needed: 2000,
  name: "Recht Fragen zu editieren",
  slug: "edit_question",
  badge_type: "edit_question",
  badge_medal_type: "silver",
  description: "Der Anwender erhält das Recht, Fragen zu editieren.",
  order: 8
})

Badges.create_badge(nil, %{
  score_needed: 2500,
  name: "Recht Antworten zu editieren",
  slug: "edit_answer",
  badge_type: "edit_answer",
  badge_medal_type: "silver",
  description: "Der Anwender erhält das Recht, Antworten zu editieren.",
  order: 9
})

Badges.create_badge(nil, %{
  score_needed: 3000,
  name: "Recht Sperr-/Entsperr-Abstimmungen zu erstellen",
  slug: "create_close_reopen_vote",
  badge_type: "create_close_reopen_vote",
  badge_medal_type: "silver",
  description: "Der Anwender erhält das Recht, Sperr- oder Entsperr-Abstimmungen zu erstellen.",
  order: 10
})

Badges.create_badge(nil, %{
  score_needed: 5000,
  name: "Zugriff auf Moderationstools",
  slug: "moderator_tools",
  badge_type: "moderator_tools",
  badge_medal_type: "gold",
  description: "Der Anwender erhält Zugriff auf Moderationstools.",
  order: 11
})

Badges.create_badge(nil, %{
  name: "Jährling",
  slug: "yearling",
  description: "Der Anwender ist ein Jahr registriert.",
  badge_type: "custom",
  badge_medal_type: "bronze",
  order: 12
})

Badges.create_badge(nil, %{
  name: "Autobiograph",
  slug: "autobiographer",
  description:
    "Der Anwender hat in seinem Profil Beschreibung, Homepage und entweder E-Mail-Adresse, Jabber-ID oder Twitter-Handle angegeben.",
  badge_type: "custom",
  badge_medal_type: "bronze",
  order: 13
})

Badges.create_badge(nil, %{
  name: "Meißel",
  slug: "chisel",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "Der Anwender hat 100 Beiträge verfasst.",
  order: 14
})

Badges.create_badge(nil, %{
  messages: 1000,
  name: "Pinsel",
  slug: "brush",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "Der Anwender hat 1.000 Beiträge verfasst.",
  order: 15
})

Badges.create_badge(nil, %{
  name: "Feder",
  slug: "quill",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "Der Anwender hat 2.500 Beiträge verfasst.",
  order: 16
})

Badges.create_badge(nil, %{
  name: "Stift",
  slug: "pen",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "Der Anwender hat 5.000 Beiträge verfasst.",
  order: 17
})

Badges.create_badge(nil, %{
  name: "Druckerpresse",
  slug: "printing_press",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "Der Anwender hat 7.500 Beiträge verfasst.",
  order: 18
})

Badges.create_badge(nil, %{
  name: "Schreibmaschine",
  slug: "typewriter",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "Der Anwender hat 10.000 Beiträge verfasst.",
  order: 19
})

Badges.create_badge(nil, %{
  name: "Nadeldrucker",
  slug: "matrix_printer",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "Der Awender hat 20.000 Beiträge verfasst.",
  order: 20
})

Badges.create_badge(nil, %{
  name: "Tintenstrahldrucker",
  slug: "inkjet_printer",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "Der Anwender hat 30.000 Beiträge verfasst.",
  order: 21
})

Badges.create_badge(nil, %{
  name: "Laserdrucker",
  slug: "laser_printer",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "Der Anwender aht 40.000 Beiträge verfasst.",
  order: 22
})

Badges.create_badge(nil, %{
  name: "1000 Affen",
  slug: "1000_monkeys",
  badge_type: "custom",
  badge_medal_type: "gold",
  description: "Der Anwender hat 50.000 Beiträge verfasst.",
  order: 23
})

Badges.create_badge(nil, %{
  name: "Der Bewerter",
  slug: "voter",
  description: "Der Anwender hat 100, 250, 500, 1000, 2500, 5000 oder 10000 Beiträge bewertet.",
  badge_type: "custom",
  badge_medal_type: "bronze",
  order: 24
})

Badges.create_badge(nil, %{
  name: "Beschenkter",
  slug: "donee",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "Eine Nachricht hat mindestens eine positive Bewertung bekommen.",
  order: 25
})

Badges.create_badge(nil, %{
  name: "Schöne Antwort",
  slug: "nice_answer",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "Eine Antwort ist mindestens fünf mal positiv bewertet worden.",
  order: 26
})

Badges.create_badge(nil, %{
  name: "Gute Antwort",
  slug: "good_answer",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "Eine Antwort ist mindestens 10 mal positive bewertet worden.",
  order: 27
})

Badges.create_badge(nil, %{
  name: "Großartige Antwort",
  slug: "great_answer",
  badge_type: "custom",
  badge_medal_type: "silver",
  description: "Eine Antwort ist mindestens 15 mal positiv bewertet worden.",
  order: 28
})

Badges.create_badge(nil, %{
  name: "Super Antwort",
  slug: "superb_answer",
  badge_type: "custom",
  badge_medal_type: "gold",
  description: "Eine Antwort ist mindestens 20 mal positiv bewertet worden.",
  order: 29
})

Badges.create_badge(nil, %{
  name: "Kontroverse",
  slug: "controverse",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "Eine Antwort ist mindestens fünf mal positiv und fünf mal negativ bewertet worden.",
  order: 30
})

Badges.create_badge(nil, %{
  name: "Enthusiast",
  slug: "enthusiast",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "Der Anwender hat mindestens einen Beitrag positiv bewertet.",
  order: 31
})

Badges.create_badge(nil, %{
  name: "Kritiker",
  slug: "critic",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "Der Anwender hat mindestens einen Beitrag negativ bewertet.",
  order: 32
})

Badges.create_badge(nil, %{
  name: "Lehrer",
  slug: "teacher",
  badge_type: "custom",
  badge_medal_type: "bronze",
  description: "Der Anwender hat einen Beitrag beantwortet, der mindestens eine positive Bewertung erhalten hat.",
  order: 33
})
