defmodule Cforum.Jobs.ForumStatsJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  import Ecto.Query, warn: false
  require Logger

  alias Cforum.Repo
  alias Cforum.Forums.Forum

  @impl Oban.Worker
  def perform(_, _) do
    Logger.info("Renerating forum statistics…")

    from(Forum, select: fragment("gen_forum_stats(forum_id::integer)"))
    |> Repo.all()
  end
end
