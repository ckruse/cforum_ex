use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :cforum, CforumWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# Watch static and templates for browser reloading.
config :cforum, CforumWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/cforum_web/views/.*(ex)$},
      ~r{lib/cforum_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

# Configure your database
config :cforum, Cforum.Repo,
  database: "cforum_development",
  hostname: "localhost",
  pool_size: 10

config :cforum, Cforum.Mailer, adapter: Swoosh.Adapters.Local, serve_mailbox: true, preview_port: 4001

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
  convert: "/usr/bin/convert",
  cfmarkdown: [
    cli: "./node_modules/.bin/babel-node ./bin/cfmarkdown2html.js",
    pwd: Path.expand("../cfmarkdown"),
    pool_size: 5
  ]

config :appsignal, :config, active: false
