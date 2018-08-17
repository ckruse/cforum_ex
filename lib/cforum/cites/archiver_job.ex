defmodule Cforum.Cites.ArchiverJob do
  alias Cforum.Accounts.Settings
  alias Cforum.ConfigManager
  alias Cforum.Cites

  require Logger

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

    cite
    |> Cites.archive_cite()
    |> update_search()
  end

  defp update_search({:ok, cite}) do
    # TODO generate a search document
    {:ok, cite}
  end

  defp update_search({:error, changeset}) do
    id = Ecto.Changeset.get_field(changeset, :cite_id)
    Logger.error("Not reindexing cite ##{id} because of database errors")
  end
end
