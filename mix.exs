defmodule Cforum.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cforum,
      version: "0.0.1",
      elixir: "~> 1.2",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      aliases: aliases(),
      deps: deps()
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
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 0.12"},
      {:number, "~> 0.5.1"},
      {:bamboo, "~> 0.8"},
      {:bamboo_smtp, "~> 1.4.0"},
      {:timex, "~> 3.1"},
      {:timex_ecto, "~> 3.2"},
      {:arc_ecto, "~> 0.7"},
      {:arc, "~> 0.8"},
      {:poolboy, "~> 1.5.1"},
      {:porcelain, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:slugify, "~> 1.1"},
      {:xml_builder, "~> 2.0.0"},
      {:quantum, "~> 2.3"},

      # testing
      {:ex_guard, "~> 1.3", only: :dev},
      {:excoveralls, "~> 0.8", only: :test},
      {:ex_machina, "~> 2.1", only: :test},
      {:faker, "~> 0.9", only: :test},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
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
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
