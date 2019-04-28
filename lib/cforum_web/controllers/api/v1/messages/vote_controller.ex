defmodule CforumWeb.Api.V1.Messages.VoteController do
  use CforumWeb, :controller

  alias Cforum.Forums
  alias Cforum.Threads
  alias Cforum.Messages
  alias Cforum.Messages.Votes

  def upvote(conn, params) do
    if Votes.upvoted?(conn.assigns.message, conn.assigns.current_user) do
      Votes.take_back_vote(conn.assigns.message, conn.assigns.current_user)
    else
      Votes.upvote(conn.assigns.message, conn.assigns.current_user, conf(conn, "vote_up_value", :int))
    end

    thread =
      Threads.get_thread_by_slug!(conn.assigns.current_forum, conn.assigns[:visible_forums], params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()

    message = Messages.get_message_from_mid!(thread, params["message_id"])

    render(conn, "vote.json", message: message)
  end

  def downvote(conn, params) do
    if Votes.downvoted?(conn.assigns.message, conn.assigns.current_user) do
      Votes.take_back_vote(conn.assigns.message, conn.assigns.current_user)
    else
      Votes.downvote(conn.assigns.message, conn.assigns.current_user, conf(conn, "vote_down_value", :int))
    end

    thread =
      Threads.get_thread_by_slug!(conn.assigns.current_forum, conn.assigns[:visible_forums], params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()

    message = Messages.get_message_from_mid!(thread, params["message_id"])

    render(conn, "vote.json", message: message)
  end

  def load_resource(conn) do
    forum = Forums.get_forum_by_slug(conn.params["forum"])

    thread =
      Threads.get_thread_by_slug!(forum, conn.assigns[:visible_forums], conn.params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()

    message = Messages.get_message_from_mid!(thread, conn.params["message_id"])

    conn
    |> Plug.Conn.assign(:current_forum, forum)
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(conn, action, resource), do: CforumWeb.Messages.VoteController.allowed?(conn, action, resource)
end
