defmodule CforumWeb.Messages.VoteController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.Threads.ThreadHelpers

  alias Cforum.Messages
  alias Cforum.Votes
  alias Cforum.Messages.MessageHelpers

  alias Cforum.Abilities
  alias Cforum.ConfigManager

  alias CforumWeb.Views.ViewHelpers.ReturnUrl

  def upvote(conn, params) do
    vote_up_value = ConfigManager.conf(conn, "vote_up_value", :int)

    message =
      if Votes.upvoted?(conn.assigns.message, conn.assigns.current_user) do
        Votes.take_back_vote(conn.assigns.message, conn.assigns.current_user)
        gettext("Successfully took back vote")
      else
        Votes.upvote(conn.assigns.message, conn.assigns.current_user, vote_up_value)
        gettext("Successfully upvoted message")
      end

    conn
    |> put_flash(:info, message)
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread, conn.assigns.message))
  end

  def downvote(conn, params) do
    vote_down_value = ConfigManager.conf(conn, "vote_down_value", :int)

    message =
      if Votes.downvoted?(conn.assigns.message, conn.assigns.current_user) do
        Votes.take_back_vote(conn.assigns.message, conn.assigns.current_user)
        gettext("Successfully took back vote")
      else
        Votes.downvote(conn.assigns.message, conn.assigns.current_user, vote_down_value)
        gettext("Successfully downvoted message")
      end

    conn
    |> put_flash(:info, message)
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread, conn.assigns.message))
  end

  def load_resource(conn) do
    thread =
      Threads.get_thread_by_slug!(conn.assigns[:current_forum], nil, ThreadHelpers.slug_from_params(conn.params))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    message = Messages.get_message_from_mid!(thread, conn.params["mid"])

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(conn, :upvote, resource) do
    {_thread, message} =
      case resource do
        {thread, message} -> {thread, message}
        _ -> {conn.assigns.thread, conn.assigns.message}
      end

    Abilities.signed_in?(conn) && Abilities.access_forum?(conn, :write) &&
      (Abilities.admin?(conn) || Abilities.badge?(conn, "upvote")) &&
      !MessageHelpers.closed?(message) && message.user_id != conn.assigns.current_user.user_id
  end

  def allowed?(conn, :downvote, resource) do
    {_thread, message} =
      case resource do
        {thread, message} -> {thread, message}
        _ -> {conn.assigns.thread, conn.assigns.message}
      end

    Abilities.signed_in?(conn) && Abilities.access_forum?(conn, :write) &&
      (Abilities.admin?(conn) || Abilities.badge?(conn, "downvote")) &&
      !MessageHelpers.closed?(message) && conn.assigns.current_user.score > 0 &&
      message.user_id != conn.assigns.current_user.user_id
  end

  def allowed?(_, _, _), do: false
end
