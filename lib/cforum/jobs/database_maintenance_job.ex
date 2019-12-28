defmodule Cforum.Jobs.DatabaseMaintenanceJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  import Ecto.Query, warn: false
  require Logger

  alias Cforum.Repo

  @impl Oban.Worker
  def perform(_, _) do
    Logger.info("Starting database maintenance…")

    Logger.info("VACCUM FULL ANALYZE…")
    Repo.query!("VACUUM FULL ANALYZE", [], timeout: :infinity, pool_timeout: :infinity)

    Logger.info("ANALYZE…")
    Repo.query!("ANALYZE", [], timeout: :infinity, pool_timeout: :infinity)

    Logger.info("REINDEX…")
    cfg = Repo.config()
    Repo.query!("REINDEX DATABASE #{cfg[:database]}", [], timeout: :infinity, pool_timeout: :infinity)

    Logger.info("database maintenance finished!")
  end
end
