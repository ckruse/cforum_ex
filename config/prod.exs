import Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :cforum, CforumWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Mix.Project.config()[:version]

# Do not print debug messages in production
config :logger, level: :info

config :cforum,
  paginator: [
    per_page: 50,
    distance: 3
  ],
  environment: Mix.env(),
  search_dict: "german"

config :appsignal, :config,
  otp_app: :cforum,
  active: true

config :cforum, Cforum.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool_size: 20
