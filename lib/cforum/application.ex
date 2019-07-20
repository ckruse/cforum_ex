defmodule Cforum.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    :telemetry.attach(
      "appsignal-ecto",
      [:cforum, :repo, :query],
      &Appsignal.Ecto.handle_event/4,
      nil
    )

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Cforum.Repo, []),
      # Start the endpoint when the application starts
      supervisor(CforumWeb.Endpoint, []),
      # Start your own worker by calling: Cforum.Worker.start_link(arg1, arg2, arg3)
      # worker(Cforum.Worker, [arg1, arg2, arg3]),
      worker(Cforum.Scheduler, []),
      worker(Cachex, [:cforum, []]),
      :poolboy.child_spec(Cforum.MarkdownRenderer.pool_name(), poolboy_config(:markdown), [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cforum.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CforumWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp poolboy_config(:markdown) do
    conf = Application.get_env(:cforum, :cfmarkdown)

    [
      {:name, {:local, Cforum.MarkdownRenderer.pool_name()}},
      {:worker_module, Cforum.MarkdownRenderer},
      {:size, Keyword.get(conf, :pool_size, 5)},
      {:max_overflow, Keyword.get(conf, :max_overflow, 2)}
    ]
  end
end
