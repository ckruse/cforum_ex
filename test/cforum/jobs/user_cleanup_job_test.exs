defmodule Cforum.Jobs.UserCleanupJobTest do
  use Cforum.DataCase

  alias Cforum.Users
  alias Cforum.Users.User
  alias Cforum.Jobs.UserCleanupJob

  test "deletes a user after 24 hours when not yet confirmed" do
    user = insert(:user, confirmation_sent_at: Timex.shift(Timex.now(), hours: -25), confirmed_at: nil)

    UserCleanupJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0, snoozed: 0, cancelled: 0, discard: 0} == Oban.drain_queue(queue: :background)

    assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.user_id) end
  end

  test "does not delete a user within the first 24 hours" do
    user = insert(:user, confirmation_sent_at: Timex.now(), confirmed_at: nil)

    UserCleanupJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0, snoozed: 0, cancelled: 0, discard: 0} == Oban.drain_queue(queue: :background)

    assert %User{user_id: id} = Users.get_user!(user.user_id)
    assert id == user.user_id
  end

  test "does not delete confirmed users" do
    user = insert(:user, confirmation_sent_at: Timex.shift(Timex.now(), hours: -25), confirmed_at: Timex.now())

    UserCleanupJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0, snoozed: 0, cancelled: 0, discard: 0} == Oban.drain_queue(queue: :background)

    assert %User{user_id: id} = Users.get_user!(user.user_id)
    assert id == user.user_id
  end

  test "deletes users with last visit > 30 days ago and no posts" do
    user = insert(:user, confirmed_at: Timex.now(), last_visit: Timex.shift(Timex.now(), days: -30))

    UserCleanupJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0, snoozed: 0, cancelled: 0, discard: 0} == Oban.drain_queue(queue: :background)

    assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.user_id) end
  end

  test "deletes users with no last visit and created at > 30 days ago and no posts" do
    user = insert(:user, confirmed_at: Timex.now(), created_at: Timex.shift(Timex.now(), days: -30))

    UserCleanupJob.new(%{}) |> Oban.insert!()
    assert %{success: 1, failure: 0, snoozed: 0, cancelled: 0, discard: 0} == Oban.drain_queue(queue: :background)

    assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.user_id) end
  end
end
