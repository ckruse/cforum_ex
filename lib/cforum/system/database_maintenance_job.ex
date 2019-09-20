defmodule Cforum.System.DatabaseMaintenanceJob do
  import Ecto.Query, warn: false
  require Logger

  alias Cforum.Repo

  def maintenance do
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
