defmodule CforumWeb.Messages.OpenCloseVoteController do
  use CforumWeb, :controller
  use Cforum.Accounts.Constants

  alias Cforum.Threads
  alias Cforum.Threads.ThreadHelpers

  alias Cforum.Messages
  alias Cforum.Messages.MessageHelpers
  alias Cforum.Messages.CloseVotes
  alias Cforum.Messages.CloseVote
  alias Cforum.ConfigManager

  alias Cforum.Abilities
  alias Cforum.Helpers

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
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, ThreadHelpers.slug_from_params(conn.params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.apply_user_infos(conn.assigns[:current_user], omit: [:read, :subscriptions, :interesting])
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

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

  @create_actions [:new_close, :create_close, :new_open, :create_open]

  def allowed?(conn, action, nil) when action in @create_actions,
    do: allowed?(conn, action, {conn.assigns.thread, conn.assigns.message})

  def allowed?(_conn, action, {%{archived: true}, _}) when action in @create_actions,
    do: false

  def allowed?(conn, action, {_thread, msg}) when action in [:new_close, :create_close] do
    (Abilities.access_forum?(conn, :moderate) || Abilities.badge?(conn, @badge_create_close_reopen_vote)) &&
      !MessageHelpers.closed?(msg) && !MessageHelpers.admin_decision?(msg) && CloseVotes.get_close_vote(msg) == nil
  end

  def allowed?(conn, action, {_thread, msg}) when action in [:new_open, :create_open] do
    (Abilities.access_forum?(conn, :moderate) || Abilities.badge?(conn, @badge_create_close_reopen_vote)) &&
      MessageHelpers.closed?(msg) && !MessageHelpers.admin_decision?(msg) && CloseVotes.get_reopen_vote(msg) == nil
  end

  def allowed?(conn, :vote, vote) do
    vote = vote || conn.assigns[:vote]

    cond do
      Helpers.blank?(vote) ->
        Abilities.badge?(conn, @badge_visit_close_reopen) ||
          Cforum.Accounts.Users.moderator?(conn.assigns[:current_user])

      vote.finished ->
        false

      vote.vote_type == false ->
        msg = get_message(conn, vote.message)

        (Abilities.access_forum?(conn, :moderate) || Abilities.badge?(conn, @badge_visit_close_reopen)) &&
          !MessageHelpers.closed?(msg) && !MessageHelpers.admin_decision?(msg)

      true ->
        msg = get_message(conn, vote.message)

        (Abilities.access_forum?(conn, :moderate) || Abilities.badge?(conn, @badge_visit_close_reopen)) &&
          MessageHelpers.closed?(msg) && !MessageHelpers.admin_decision?(msg)
    end
  end

  def allowed?(_, _, _), do: false

  defp get_message(conn, %Ecto.Association.NotLoaded{}), do: conn.assigns.message
  defp get_message(_, msg), do: msg
end
