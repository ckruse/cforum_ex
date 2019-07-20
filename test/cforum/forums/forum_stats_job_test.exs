defmodule Cforum.Forums.ForumStatsJobTest do
  use Cforum.DataCase

  test "generates stats" do
    insert(:forum)
    Cforum.Forums.ForumStatsJob.gen_stats()
  end
end
