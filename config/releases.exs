import Config

config :cforum, CforumWeb.Endpoint,
  secret_key_base: System.fetch_env!("CF_SECRET_KEY"),
  http: [port: System.fetch_env!("CF_PORT"), ip: {127, 0, 0, 1}],
  url: [host: System.fetch_env!("CF_HOST"), port: 443, scheme: "https"],
  live_view: [signing_salt: System.fetch_env!("CF_SIGNING_SALT")]

config :cforum,
  mail_sender: System.fetch_env!("CF_MAIL_SENDER"),
  base_url: System.fetch_env!("CF_BASE_URL"),
  uploads_dir: System.fetch_env!("CF_UPLOADS_DIR"),
  media_dir: System.fetch_env!("CF_MEDIA_DIR"),
  avatar_dir: System.fetch_env!("CF_AVATAR_DIR"),
  avatar_url: System.fetch_env!("CF_AVATAR_URL"),
  convert: System.fetch_env!("CF_CONVERT_PATH"),
  cfmarkdown: [
    cli: "./node_modules/.bin/babel-node ./bin/cfmarkdown2html.js",
    pwd: System.fetch_env!("CF_MARKDOWN_PATH"),
    pool_size: 30,
    max_overflow: 15
  ]

config :cforum, Cforum.Repo,
  username: System.fetch_env!("CF_DB_USERNAME"),
  password: System.fetch_env!("CF_DB_PASSWORD"),
  database: System.fetch_env!("CF_DB_NAME")

config :cforum, Cforum.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: System.fetch_env!("CF_SMTP_SERVER"),
  username: System.fetch_env!("CF_SMTP_USER"),
  password: System.fetch_env!("CF_SMTP_PASS"),
  ssl: false,
  tls: :always,
  auth: :always,
  port: 25

config :appsignal, :config,
  otp_app: :cforum,
  ecto_repos: [],
  active: true,
  name: "SELFHTML Forum",
  push_api_key: System.fetch_env!("CF_APPSIGNAL_KEY"),
  env: :prod,
  ignore_errors: ["Ecto.NoResultsError", "Phoenix.Router.NoRouteError"]
