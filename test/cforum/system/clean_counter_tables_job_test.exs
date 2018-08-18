defmodule Cforum.System.CleanCounterTablesJobTest do
  use Cforum.DataCase

  test "cleans counter tables" do
    insert(:forum)
    Cforum.System.CleanCounterTablesJob.clean_tables()
  end
end
