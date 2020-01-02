defmodule CforumWeb.VotingAreaView do
  use CforumWeb, :view

  alias Cforum.Messages.MessageHelpers
  alias Cforum.Votes

  alias Cforum.Abilities

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def acceptance_status?(conn, message, top),
    do: MessageHelpers.accepted?(message) && (top || !Abilities.accept?(conn, message))

  def voting_svg(conn, path) do
    [
      {:safe,
       "<svg width=\"150\" height=\"150\" viewBox=\"0 0 150 150\" xmlns=\"http://www.w3.org/2000/svg\"><use xlink:href=\""},
      Routes.static_path(conn, "/images/voting-area-icons.svg"),
      "#",
      path,
      {:safe, "\"></use></svg>"}
    ]
  end

  def acceptance_button(conn, thread, message, top) do
    cond do
      top ->
        nil

      Abilities.may?(conn, "messages/accept", :accept, {thread, message}) ->
        ViewHelpers.Button.cf_button(
          # voting_svg(conn, "accept"),
          [{:safe, "<span>"}, gettext("accept answer"), {:safe, "</span>"}],
          to: Path.message_path(conn, :accept, thread, message),
          class: "accept unaccepted-answer",
          params: ViewHelpers.std_args(conn),
          title: gettext("accept answer")
        )

      Abilities.may?(conn, "messages/accept", :unaccept, {thread, message}) ->
        ViewHelpers.Button.cf_button(
          # voting_svg(conn, "accept"),
          [{:safe, "<span>"}, gettext("unaccept answer"), {:safe, "</span>"}],
          to: Path.message_path(conn, :unaccept, thread, message),
          class: "accept accepted-answer",
          params: ViewHelpers.std_args(conn),
          title: gettext("unaccept answer")
        )

      acceptance_status?(conn, message, top) ->
        # [{:safe, "<span class=\"accepted-answer accept disabled\">"}, voting_svg(conn, "accept"), {:safe, "</span>"}]
        [{:safe, "<span class=\"accepted-answer accept disabled\"> </span>"}]

      true ->
        ""
    end
  end

  def active_upvoting_button(message, user) do
    if Votes.upvoted?(message, user), do: " active"
  end

  def active_downvoting_button(message, user) do
    if Votes.downvoted?(message, user), do: " active"
  end

  def vote_up_button(conn, thread, message, top) do
    if top do
      nil
    else
      # Abilities.may?(conn, "messages/vote", :upvote, {thread, message}) ->
      ViewHelpers.Button.cf_button(
        [{:safe, "<span>"}, gettext("vote up"), {:safe, "</span>"}],
        to: Path.message_path(conn, :upvote, thread, message),
        class: "vote-button vote-up #{active_upvoting_button(message, conn.assigns.current_user)}",
        params: ViewHelpers.std_args(conn),
        disabled: !Abilities.may?(conn, "messages/vote", :upvote, {thread, message}),
        title: gettext("vote up")
      )

      # true ->
      #   [{:safe, "<span class=\"vote-button vote-up disabled\">"}, voting_svg(conn, "vote-up"), {:safe, "</span>"}]
    end
  end

  def vote_down_button(conn, thread, message, top) do
    if top do
      nil
    else
      # Abilities.may?(conn, "messages/vote", :downvote, {thread, message}) ->
      ViewHelpers.Button.cf_button(
        [{:safe, "<span>"}, gettext("vote down"), {:safe, "</span>"}],
        to: Path.message_path(conn, :downvote, thread, message),
        class: "vote-button vote-down #{active_downvoting_button(message, conn.assigns.current_user)}",
        params: ViewHelpers.std_args(conn),
        disabled: !Abilities.may?(conn, "messages/vote", :downvote, {thread, message}),
        title: gettext("vote down")
      )

      # true ->
      #   [{:safe, "<span class=\"vote-button vote-down disabled\">"}, voting_svg(conn, "vote-down"), {:safe, "</span>"}]
    end
  end
end
