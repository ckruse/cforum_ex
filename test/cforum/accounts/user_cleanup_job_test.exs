defmodule Cforum.Forums.UserCleanupJobTest do
  use Cforum.DataCase

  alias Cforum.Accounts.{Users, User, UserCleanupJob}

  test "deletes a user after 24 hours when not yet confirmed" do
    user = insert(:user, confirmation_sent_at: Timex.shift(Timex.now(), hours: -25), confirmed_at: nil)
    UserCleanupJob.cleanup()
    assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.user_id) end
  end

  test "does not delete a user within the first 24 hours" do
    user = insert(:user, confirmation_sent_at: Timex.now(), confirmed_at: nil)
    UserCleanupJob.cleanup()
    assert %User{user_id: id} = Users.get_user!(user.user_id)
    assert id == user.user_id
  end

  test "does not delete confirmed users" do
    user = insert(:user, confirmation_sent_at: Timex.shift(Timex.now(), hours: -25), confirmed_at: Timex.now())
    UserCleanupJob.cleanup()
    assert %User{user_id: id} = Users.get_user!(user.user_id)
    assert id == user.user_id
  end
end
