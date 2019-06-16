defmodule Cforum.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cforum,
      version: "5.0.0-beta23",
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
    [mod: {Cforum.Application, []}, extra_applications: [:logger, :runtime_tools]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 0.12"},
      {:number, "~> 0.5.1"},
      {:bamboo, "~> 1.1"},
      {:bamboo_smtp, "~> 1.6"},
      {:timex, "~> 3.1"},
      {:arc_ecto, "~> 0.7"},
      {:arc, "~> 0.8"},
      {:poolboy, "~> 1.5.1"},
      {:porcelain, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:slugify, "~> 1.1"},
      {:xml_builder, "~> 2.0.0"},
      {:quantum, "~> 2.3"},
      {:elixir_uuid, "~> 1.2"},
      {:cachex, "~> 3.1"},
      {:earmark, "~> 1.3.0"},
      {:html_entities, "~> 0.4"},
      {:nimble_parsec, "~> 0.2"},
      {:appsignal, "~> 1.0"},

      # testing
      {:excoveralls, "~> 0.8", only: :test},
      {:ex_machina, "~> 2.2", only: :test},
      {:faker, "~> 0.9", only: :test},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},

      # build & delivery
      {:distillery, "~> 2.0"},
      {:edeliver, ">= 1.6.0"}
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
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.init": ["ecto.create", "ecto.load"],
      "migrate.cf4": [
        "run priv/migrate_db.exs",
        "run priv/delete_archived_read_messages.exs",
        "run priv/merge_tags.exs",
        "ecto.migrate",
        "run priv/migrate_db_after_migrations.exs"
      ],
      "build.release": ["cmd ./.deliver/build -t release"],
      "build.upgrade": ["cmd ./.deliver/build -t upgrade"],
      "deploy.release": ["edeliver deploy release to production"],
      "deploy.upgrade": ["edeliver deploy upgrade to production"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
