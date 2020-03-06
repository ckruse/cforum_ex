defmodule Cforum.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cforum,
      version: "5.3.48",
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
      {:gettext, "0.17.1"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 0.12"},
      {:number, "~> 0.5.1"},
      {:swoosh, "~> 0.24.3"},
      {:gen_smtp, "~> 0.13"},
      {:phoenix_swoosh, "~> 0.2"},
      {:timex, "~> 3.1"},
      {:waffle_ecto, "~> 0.0.7"},
      {:waffle, "~> 1.0.0"},
      {:poolboy, "~> 1.5.1"},
      {:porcelain, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:slugify, "~> 1.1"},
      {:xml_builder, "~> 2.0.0"},
      {:oban, "~> 1.0"},
      {:elixir_uuid, "~> 1.2"},
      {:cachex, "~> 3.1"},
      {:earmark, "~> 1.3.0"},
      {:html_entities, "~> 0.4"},
      {:nimble_parsec, "~> 0.2"},
      {:appsignal, "~> 1.0"},

      # oban web view
      {:phoenix_live_view, "~> 0.6"},
      {:floki, ">= 0.0.0", only: :test},
      {:oban_web, "~> 1.0", organization: "oban"},

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
