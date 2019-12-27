use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cforum, CforumWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
# config :logger, :console, format: "[$level] $message\n"

# Configure your database
config :cforum, Cforum.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "cforum_test",
  username: System.get_env("DB_USER", System.get_env("USER")),
  password: System.get_env("DB_PASS"),
  hostname: System.get_env("DB_HOST", "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox

config :cforum, Cforum.Mailer, adapter: Swoosh.Adapters.Test

config :cforum,
  mail_sender: "cforum@wwwtech.de",
  paginator: [
    per_page: 50,
    distance: 3
  ],
  base_url: "http://localhost:4000/",
  environment: Mix.env(),
  search_dict: "german",
  uploads_dir: Path.expand("../priv/uploads", __DIR__),
  media_dir: Path.expand("../priv/uploads/pictures", __DIR__),
  avatar_dir: Path.expand("../priv/uploads/users/avatars", __DIR__),
  avatar_url: "/uploads/users/avatars",
  cfmarkdown: [
    # cli: "./node_modules/.bin/babel-node ./bin/cfmarkdown2html.js",
    # pwd: Path.expand("../cfmarkdown"),
    pool_size: 10
  ]
