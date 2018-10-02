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
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :cforum, Cforum.Mailer, adapter: Bamboo.TestAdapter

config :cforum,
  mail_sender: "cforum@wwwtech.de",
  paginator: [
    per_page: 50,
    distance: 3
  ],
  base_url: "http://localhost:4000/",
  environment: Mix.env(),
  search_dict: "german",
  media_dir: "/home/ckruse/sites/cforum_elixir/priv/uploads/pictures",
  cfmarkdown: [
    cli: "./node_modules/.bin/babel-node ./bin/cfmarkdown2html.js",
    pwd: "/home/ckruse/dev/cfmarkdown"
  ]
