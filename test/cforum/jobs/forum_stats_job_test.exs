defmodule Cforum.Jobs.ForumStatsJobTest do
  use Cforum.DataCase

  test "generates stats" do
    insert(:forum)
    Cforum.Jobs.ForumStatsJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0} == Oban.drain_queue(queue: :background)
  end
end
