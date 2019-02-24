alias Cforum.Repo

Repo.query!("UPDATE search_sections SET section_type = 'forum' WHERE forum_id IS NOT NULL")
Repo.query!("UPDATE search_sections SET section_type = 'cites' WHERE forum_id IS NULL")
