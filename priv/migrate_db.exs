alias Cforum.Repo

Repo.query!("""
  ALTER TABLE schema_migrations
    ALTER COLUMN version TYPE bigint USING version::bigint;
""")

Repo.query!("""
  ALTER TABLE schema_migrations
    ADD COLUMN inserted_at TIMESTAMP WITHOUT TIME ZONE;
""")
