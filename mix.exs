defmodule Cforum.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cforum,
      version: "5.6.26",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_deps: :transitive, ignore_warnings: ".dialyzer_ignore.exs"]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Cforum.Application, []}, extra_applications: [:logger, :runtime_tools, :os_mon]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:plug_cowboy, "~> 2.1"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto, "~> 3.5.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_live_dashboard, "~> 0.1"},
      {:gettext, "0.18.0"},
      {:plug, "~> 1.7"},
      {:bcrypt_elixir, "~> 2.0"},
      {:number, "~> 1.0"},
      {:swoosh, "~> 1.3"},
      {:gen_smtp, "~> 1.0"},
      {:phoenix_swoosh, "~> 0.2"},
      {:timex, "~> 3.1"},
      {:waffle_ecto, "~> 0.0.7"},
      {:waffle, "~> 1.1.0"},
      {:poolboy, "~> 1.5.1"},
      {:jason, "~> 1.0"},
      {:slugify, "~> 1.1"},
      {:xml_builder, "~> 2.1.1"},
      {:oban, "~> 2.3"},
      {:tzdata, "~> 1.1.0", override: true},
      {:elixir_uuid, "~> 1.2"},
      {:cachex, "~> 3.1"},
      {:earmark, "~> 1.3.0"},
      {:html_entities, "~> 0.4"},
      {:nimble_parsec, "~> 1.1"},
      {:appsignal_phoenix, "~> 2.0.0"},
      {:telemetry_poller, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:ecto_psql_extras, "~> 0.2"},
      {:gh_webhook_plug, "~> 0.0.5"},

      # testing
      {:excoveralls, "~> 0.8", only: :test},
      {:ex_machina, "~> 2.2", only: :test},
      {:faker, "~> 0.9", only: :test},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 1.0.0-rc.6", only: [:dev], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.load", "migrate.cf4", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.init": ["ecto.create", "ecto.load", "run priv/repo/seeds.exs"],
      "migrate.cf4": [
        "run priv/migrate_db.exs",
        "run priv/delete_archived_read_messages.exs",
        "run priv/merge_tags.exs",
        "ecto.migrate",
        "run priv/migrate_db_after_migrations.exs"
      ],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      build: "cmd ./.build/build",
      deploy: "cmd ./.build/deploy"
    ]
  end
end
