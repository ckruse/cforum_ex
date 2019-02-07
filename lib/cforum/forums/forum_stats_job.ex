defmodule Cforum.Forums.ForumStatsJob do
  use Appsignal.Instrumentation.Decorators

  import Ecto.Query, warn: false
  require Logger

  alias Cforum.Repo
  alias Cforum.Forums.Forum

  @decorate transaction()
  def gen_stats do
    Logger.info("Renerating forum statistics…")

    from(Forum, select: fragment("gen_forum_stats(forum_id::integer)"))
    |> Repo.all()
  end
end
