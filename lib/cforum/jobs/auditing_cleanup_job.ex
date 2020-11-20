defmodule Cforum.Jobs.AuditingCleanupJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.System.Auditing

  @impl Oban.Worker
  def perform(_) do
    from(au in Auditing, where: au.created_at < ago(12, "month"))
    |> Repo.delete_all()

    :ok
  end
end
