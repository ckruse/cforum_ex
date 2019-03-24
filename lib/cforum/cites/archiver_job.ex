defmodule Cforum.Cites.ArchiverJob do
  use Appsignal.Instrumentation.Decorators

  alias Cforum.Accounts.Settings
  alias Cforum.ConfigManager
  alias Cforum.Cites

  require Logger

  @decorate transaction()
  def archive do
    setting = Settings.get_global_setting()
    min_age = ConfigManager.conf(setting, "cites_min_age_to_archive", :int)
    cites = Cites.list_cites_to_archive(min_age)

    Logger.info("Running cites archiver for #{length(cites)} cites (min age: #{min_age} weeks)")
    Enum.each(cites, &archive_cite(&1, Cites.score(&1)))
    Logger.info("cites archiver: done!")
  end

  defp archive_cite(cite, score) when score <= 0 do
    Logger.info("discarding cite ##{cite.cite_id} with score #{score}")
    Cites.delete_cite(nil, cite)
  end

  defp archive_cite(cite, score) do
    Logger.info("archiving cite ##{cite.cite_id} with score #{score}")
    Cites.archive_cite(cite)
  end
end
