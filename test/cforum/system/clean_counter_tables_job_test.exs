defmodule Cforum.System.CleanCounterTablesJobTest do
  use Cforum.DataCase

  test "generates stats" do
    insert(:forum)
    Cforum.System.CleanCounterTablesJob.clean_tables()
  end
end
