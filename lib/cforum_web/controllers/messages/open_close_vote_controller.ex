defmodule CforumWeb.Messages.OpenCloseVoteController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Messages, Threads, CloseVotes, CloseVote}
  alias Cforum.Accounts.Badge

  def new_close(conn, _params) do
    changeset = CloseVotes.new_change_vote(%CloseVote{})
    render(conn, "new_close.html", changeset: changeset)
  end

  def create_close(conn, %{"close_vote" => close_vote_params}) do
    case CloseVotes.create_vote(conn.assigns.current_user, conn.assigns.message, close_vote_params) do
      {:ok, _vote} ->
        conn
        |> put_flash(:info, gettext("Close vote has successfully been created."))
        |> redirect(to: Path.message_path(conn, :show, conn.assigns.thread, conn.assigns.message))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new_close.html", changeset: changeset)
    end
  end

  def new_open(conn, _params) do
    changeset = CloseVotes.new_change_vote(%CloseVote{reason: "custom"})
    render(conn, "new_open.html", changeset: changeset)
  end

  def create_open(conn, %{"close_vote" => close_vote_params}) do
    case CloseVotes.create_reopen_vote(conn.assigns.current_user, conn.assigns.message, close_vote_params) do
      {:ok, _vote} ->
        conn
        |> put_flash(:info, gettext("Reopen vote has successfully been created."))
        |> redirect(to: Path.message_path(conn, :show, conn.assigns.thread, conn.assigns.message))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new_open.html", changeset: changeset)
    end
  end

  def vote(conn, _params) do
    vote = conn.assigns.vote

    info =
      if CloseVotes.has_voted?(conn.assigns.current_user, vote) do
        CloseVotes.take_back_vote(conn.assigns.current_user, vote)
        gettext("Successfully took back vote")
      else
        CloseVotes.vote(conn.assigns.current_user, vote)
        gettext("Successfully voted")
      end

    conn
    |> put_flash(:info, info)
    |> redirect(to: Path.message_path(conn, :show, conn.assigns.thread, conn.assigns.message))
  end

  def load_resource(conn) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, Threads.slug_from_params(conn.params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.apply_user_infos(conn.assigns[:current_user], omit: [:read, :subscriptions, :interesting])
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["mid"])

    vote =
      if conn.params["id"] do
        CloseVotes.get_vote!(conn.params["id"])
      else
        nil
      end

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
    |> Plug.Conn.assign(:vote, vote)
  end

  def allowed?(conn, action, msg) when action in [:new_close, :create_close] do
    msg = msg || conn.assigns.message

    (Abilities.access_forum?(conn, :moderate) || Abilities.badge?(conn, Badge.create_close_reopen_vote())) &&
      !Messages.closed?(msg) &&
      !Messages.admin_decision?(msg) && CloseVotes.get_close_vote(msg) == nil
  end

  def allowed?(conn, action, msg) when action in [:new_open, :create_open] do
    msg = msg || conn.assigns.message

    (Abilities.access_forum?(conn, :moderate) || Abilities.badge?(conn, Badge.create_close_reopen_vote())) &&
      Messages.closed?(msg) &&
      !Messages.admin_decision?(msg) && CloseVotes.get_reopen_vote(msg) == nil
  end

  def allowed?(conn, :vote, vote) do
    vote = vote || conn.assigns.vote
    msg = get_message(conn, vote.message)

    cond do
      blank?(vote) || vote.finished ->
        false

      vote.vote_type == false ->
        (Abilities.access_forum?(conn, :moderate) || Abilities.badge?(conn, Badge.visit_close_reopen())) &&
          !Messages.closed?(msg) &&
          !Messages.admin_decision?(msg)

      true ->
        (Abilities.access_forum?(conn, :moderate) || Abilities.badge?(conn, Badge.visit_close_reopen())) &&
          Messages.closed?(msg) &&
          !Messages.admin_decision?(msg)
    end
  end

  def allowed?(_, _, _), do: false

  defp get_message(conn, %Ecto.Association.NotLoaded{}), do: conn.assigns.message
  defp get_message(_, msg), do: msg
end
