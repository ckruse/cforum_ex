defmodule CforumWeb.Api.V1.Messages.OpenCloseVoteController do
  use CforumWeb, :controller

  alias Cforum.ConfigManager
  alias Cforum.Forums
  alias Cforum.Threads
  alias Cforum.Messages
  alias Cforum.Messages.CloseVotes

  def vote(conn, _params) do
    vote = conn.assigns.vote
    user = conn.assigns.current_user

    info =
      if CloseVotes.has_voted?(user, vote) do
        CloseVotes.take_back_vote(user, vote)
        gettext("Successfully took back vote")
      else
        CloseVotes.vote(user, vote)
        gettext("Successfully voted")
      end

    json(conn, %{
      "status" => "ok",
      "message" => info,
      "votes" => CloseVotes.no_votes(vote),
      "votes_needed" => ConfigManager.conf(conn, "close_vote_votes")
    })
  end

  def load_resource(conn) do
    forum = Forums.get_forum_by_slug(conn.params["forum"])

    thread =
      Threads.get_thread_by_slug!(forum, conn.assigns[:visible_forums], conn.params["slug"])
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()

    message = Messages.get_message_from_mid!(thread, conn.params["message_id"])
    vote = CloseVotes.get_vote!(conn.params["id"])

    conn
    |> Plug.Conn.assign(:current_forum, forum)
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
    |> Plug.Conn.assign(:vote, vote)
  end

  def allowed?(conn, action, resource), do: CforumWeb.Messages.OpenCloseVoteController.allowed?(conn, action, resource)
end
