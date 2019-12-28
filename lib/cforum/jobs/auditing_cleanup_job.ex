defmodule Cforum.Jobs.AuditingCleanupJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  import Ecto.Query, warn: false
  require Logger

  alias Cforum.Repo
  alias Cforum.System.Auditing

  def perform(_, _) do
    Logger.info("Starting auditing cleanup…")

    from(au in Auditing, where: au.created_at < ago(12, "month"))
    |> Repo.delete_all()

    Logger.info("auditing cleanup finished!")
  end
end
