defmodule Cforum.Cites.ArchiverJobTest do
  use Cforum.DataCase

  alias Cforum.Cites.ArchiverJob
  alias Cforum.Cites
  alias Cforum.Cites.Vote
  alias CforumWeb.Router.Helpers

  test "archive/0 deletes an cite with negative score" do
    cite = insert(:cite, created_at: Timex.now() |> Timex.shift(weeks: -3))
    insert(:cite_vote, cite: cite, vote_type: Vote.downvote())

    ArchiverJob.archive()

    assert Cites.list_cites(false) == []
    assert Cites.list_cites(true) == []
  end

  test "archive/0 deletes an cite with score=0" do
    insert(:cite, created_at: Timex.now() |> Timex.shift(weeks: -3))

    ArchiverJob.archive()

    assert Cites.list_cites(false) == []
    assert Cites.list_cites(true) == []
  end

  test "archive/0 archives an cite with positive score" do
    cite = insert(:cite, created_at: Timex.now() |> Timex.shift(weeks: -3))
    insert(:cite_vote, cite: cite, vote_type: Vote.upvote())

    ArchiverJob.archive()

    assert Cites.list_cites(false) == []
    assert Enum.map(Cites.list_cites(true), & &1.cite_id) == [cite.cite_id]
  end

  test "archive/0 ignores already archived cites" do
    cite = insert(:cite, created_at: Timex.now() |> Timex.shift(weeks: -3), archived: true)
    insert(:cite_vote, cite: cite, vote_type: Vote.downvote())

    ArchiverJob.archive()

    assert Cites.list_cites(false) == []
    assert Enum.map(Cites.list_cites(true), & &1.cite_id) == [cite.cite_id]
  end

  test "archive/0 creates a search document for a cite to archive" do
    cite = insert(:cite, created_at: Timex.now() |> Timex.shift(weeks: -3))
    insert(:cite_vote, cite: cite, vote_type: Vote.upvote())

    ArchiverJob.archive()

    assert Cforum.Search.get_document_by_url(Helpers.cite_url(CforumWeb.Endpoint, :show, cite))
  end
end
