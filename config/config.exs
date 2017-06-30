# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :cforum,
  ecto_repos: [Cforum.Repo]

# Configures the endpoint
config :cforum, Cforum.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "w/W7vB8NBsnCLFPZfPrUK3IUvyfEZv/+kIYUAa7YSfAjLg/aM61tsp6K+vnrD6FF",
  render_errors: [view: Cforum.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Cforum.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :cforum, Cforum.Web.Gettext,
        default_locale: "de"

config :number, delimit: [ precision: 2,
                           delimiter: ".",
                           separator: "," ]

config :cforum,
  mail_sender: "cforum@wwwtech.de",
  paginator: [
    per_page: 50,
    distance: 3
  ]

config :arc,
  storage: Arc.Storage.Local

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
