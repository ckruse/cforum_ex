defmodule Cforum.OpenClose do
  alias Cforum.Repo
  alias Cforum.OpenClose.State

  def get_open_closed_state(user, thread),
    do: Repo.get_by(OpenCloseState, user_id: user.user_id, thread_id: thread.thread_id)

  def open_thread(user, thread) do
    oc = get_open_closed_state(user, thread)

    if oc != nil && oc.state != "open" do
      Repo.delete(oc)
    else
      %State{}
      |> State.changeset(%{user_id: user.user_id, thread_id: thread.thread_id, state: "open"})
      |> Repo.insert()
    end
  end

  def close_thread(user, thread) do
    oc = get_open_closed_state(user, thread)

    if oc != nil && oc.state != "closed" do
      Repo.delete(oc)
    else
      %State{}
      |> State.changeset(%{user_id: user.user_id, thread_id: thread.thread_id, state: "closed"})
      |> Repo.insert()
    end
  end
end
