use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cforum, CforumWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :cforum, Cforum.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "cforum_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :cforum, Cforum.Mailer, adapter: Bamboo.TestAdapter
