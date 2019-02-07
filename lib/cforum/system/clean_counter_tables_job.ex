defmodule Cforum.System.CleanCounterTablesJob do
  use Appsignal.Instrumentation.Decorators

  import Ecto.Query, warn: false
  require Logger

  alias Cforum.Repo
  alias Cforum.Forums.Forum

  @decorate transaction()
  def clean_tables do
    Logger.info("Cleaning up counter tables…")

    from(forum in Forum,
      select: fragment("counter_table_get_count('threads', forum_id)")
    )
    |> Repo.all()

    from(forum in Forum,
      select: fragment("counter_table_get_count('messages', forum_id)")
    )
    |> Repo.all()
  end
end
