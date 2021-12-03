defmodule Cforum.Jobs.UserMailerJobTest do
  use Cforum.DataCase, async: true

  import Swoosh.TestAssertions

  setup do
    user = insert(:user)
    {:ok, user: user}
  end

  test "it sends a reset password mail", %{user: user} do
    Cforum.Jobs.UserMailerJob.enqueue(user, "reset_password")
    assert %{success: 1, failure: 0, snoozed: 0} == Oban.drain_queue(queue: :mails)
    assert_email_sent(to: {user.username, user.email})
  end

  test "it sends a confirm user mail", %{user: user} do
    Cforum.Jobs.UserMailerJob.enqueue(user, "confirm_user")
    assert %{success: 1, failure: 0, snoozed: 0} == Oban.drain_queue(queue: :mails)
    assert_email_sent(to: {user.username, user.email})
  end
end
