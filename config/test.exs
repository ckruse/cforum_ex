use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cforum, Cforum.Web.Endpoint,
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

config :guardian, Guardian,
  issuer: "Cforum",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: "s20ZSRaWh1d2fAv/3es69BvqZahWfvBLEsIxCpd8srjFtKjSC3JPe5yANwgpM4SJ",
  serializer: Cforum.GuardianSerializer
