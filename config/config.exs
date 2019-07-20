# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :cforum, ecto_repos: [Cforum.Repo]

# Configures the endpoint
config :cforum, CforumWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "w/W7vB8NBsnCLFPZfPrUK3IUvyfEZv/+kIYUAa7YSfAjLg/aM61tsp6K+vnrD6FF",
  render_errors: [view: CforumWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Cforum.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :cforum, CforumWeb.Gettext, default_locale: "de"

config :number, delimit: [precision: 2, delimiter: ".", separator: ","]

config :arc, storage: Arc.Storage.Local
config :porcelain, driver: Porcelain.Driver.Basic
config :timex, default_locale: "de"

config :cforum, Cforum.Scheduler,
  jobs: [
    {"@hourly", {Cforum.Forums.ArchiverJob, :archive, []}},
    {"@daily", {Cforum.Cites.ArchiverJob, :archive, []}},
    {"@daily", {Cforum.Accounts.UserCleanupJob, :cleanup, []}},
    {"@daily", {Cforum.Forums.ForumStatsJob, :gen_stats, []}},
    {"@monthly", {Cforum.System.DatabaseMaintenanceJob, :maintenance, []}},
    {"@daily", {Cforum.System.AuditingCleanupJob, :maintenance, []}},
    {"@daily", {Cforum.Accounts.YearlingBadgeDistributorJob, :perform, []}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
