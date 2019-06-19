defmodule CforumWeb.Users.UserController do
  use CforumWeb, :controller

  alias Cforum.Accounts.Users

  alias Cforum.Threads.Thread

  alias Cforum.Messages.Message
  alias Cforum.Messages.MessagesUsers

  alias Cforum.Messages.Vote
  alias Cforum.Messages.Votes

  alias Cforum.Accounts.Score

  alias CforumWeb.Sortable
  alias CforumWeb.Paginator

  def index(conn, params) do
    {sort_params, conn} = Sortable.sort_collection(conn, [:username, :score, :activity, :created_at])
    count = Users.count_users()
    paging = Paginator.paginate(count, page: params["p"])
    users = Users.list_users(limit: paging.params, order: sort_params, search: params["s"])

    render(conn, "index.html", users: users, paging: paging, s: params["s"])
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    forum_ids = Enum.map(conn.assigns[:visible_forums], & &1.forum_id)
    messages_count = MessagesUsers.count_messages_for_user(user, forum_ids)
    tags_cnt = MessagesUsers.count_messages_per_tag_for_user(user, forum_ids)

    last_messages =
      user
      |> MessagesUsers.list_messages_for_user(forum_ids, limit: [quantity: 5, offset: 0])
      |> Enum.map(fn msg ->
        thread = %Thread{msg.thread | message: msg}
        %Message{msg | thread: thread}
      end)

    point_msgs =
      user
      |> MessagesUsers.list_best_scored_messages_for_user(forum_ids)
      |> Enum.map(fn msg ->
        thread = %Thread{msg.thread | message: msg}
        %Message{msg | thread: thread}
      end)

    scored_msgs =
      user
      |> MessagesUsers.list_scored_msgs_for_user_in_perspective(conn.assigns[:current_user], forum_ids)
      |> Enum.reduce({%{}, 0}, fn score, {msgs, fake_id} ->
        m =
          case score.vote do
            nil ->
              score.message

            v ->
              v.message
          end

        {new_fid, id} =
          if m == nil,
            do: {fake_id + 1, "fake-#{fake_id}"},
            else: {fake_id, m.message_id}

        {Map.update(msgs, id, [score], fn scores -> [score | scores] end), new_fid}
      end)
      |> (fn {msgs, _} -> msgs end).()
      |> Map.values()
      |> Enum.sort(fn a, b ->
        List.last(a).created_at >= List.last(b).created_at
      end)

    render(
      conn,
      "show.html",
      user: user,
      messages_count: messages_count,
      last_messages: last_messages,
      tags_cnt: tags_cnt,
      point_msgs: point_msgs,
      badges: Users.unique_badges(user),
      jabber_id: Users.conf(user, "jabber_id"),
      twitter_handle: Users.conf(user, "twitter_handle"),
      user_url: Users.conf(user, "url"),
      description: Users.conf(user, "description"),
      scored_msgs: scored_msgs
    )
  end

  def show_messages(conn, %{"id" => id} = params) do
    user = Users.get_user!(id)
    forum_ids = Enum.map(conn.assigns[:visible_forums], & &1.forum_id)

    count = MessagesUsers.count_messages_for_user(user, forum_ids)
    paging = Paginator.paginate(count, page: params["p"])

    entries = MessagesUsers.list_messages_for_user(user, forum_ids, limit: paging.params)

    messages =
      Enum.map(entries, fn msg ->
        thread = %Thread{msg.thread | message: msg}
        %Message{msg | thread: thread}
      end)

    render(
      conn,
      "show_messages.html",
      user: user,
      messages: messages,
      paging: paging
    )
  end

  def show_scores(conn, %{"id" => id} = params) do
    user = Users.get_user!(id)
    forum_ids = Enum.map(conn.assigns[:visible_forums], & &1.forum_id)

    count = MessagesUsers.count_scored_msgs_for_user_in_perspective(user, conn.assigns[:current_user], forum_ids)
    paging = Paginator.paginate(count, page: params["p"])

    messages =
      MessagesUsers.list_scored_msgs_for_user_in_perspective(
        user,
        conn.assigns[:current_user],
        forum_ids,
        paging.params
      )

    scores =
      Enum.map(messages, fn score ->
        msg = Score.get_message(score)
        thread = %Thread{msg.thread | message: msg}
        %Score{score | message: %Message{msg | thread: thread}}
      end)

    render(
      conn,
      "show_scores.html",
      user: user,
      paging: paging,
      scores: scores
    )
  end

  def show_votes(conn, %{"id" => id} = params) do
    user = Users.get_user!(id)
    forum_ids = Enum.map(conn.assigns[:visible_forums], & &1.forum_id)

    count = Votes.count_votes_for_user(user, forum_ids)
    paging = Paginator.paginate(count, page: params["p"])

    entries = Votes.list_votes_for_user(user, forum_ids, limit: paging.params)

    votes =
      Enum.map(entries, fn vote ->
        thread = %Cforum.Threads.Thread{vote.message.thread | message: vote.message}
        %Vote{vote | message: %Cforum.Messages.Message{vote.message | thread: thread}}
      end)

    render(
      conn,
      "show_votes.html",
      user: user,
      paging: paging,
      votes: votes
    )
  end

  def edit(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    forum_ids = Enum.map(conn.assigns[:visible_forums], & &1.forum_id)
    messages_count = MessagesUsers.count_messages_for_user(user, forum_ids)
    changeset = Users.change_user(user)

    render(conn, "edit.html", user: user, changeset: changeset, messages_count: messages_count)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    case Users.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User updated successfully."))
        |> redirect(to: Routes.user_path(conn, :edit, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        forum_ids = Enum.map(conn.assigns[:visible_forums], & &1.forum_id)
        messages_count = MessagesUsers.count_messages_for_user(user, forum_ids)

        render(conn, "edit.html", user: user, changeset: changeset, messages_count: messages_count)
    end
  end

  def confirm_delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "confirm_delete.html", user: user)
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, _user} = Users.delete_user(nil, user)

    conn
    |> put_flash(:info, gettext("User deleted successfully."))
    |> redirect(to: Routes.user_path(conn, :index))
  end

  def allowed?(_conn, action, _) when action in [:index, :show, :show_messages, :show_scores], do: true

  def allowed?(conn, :update, resource) do
    cuser = conn.assigns[:current_user]

    uid =
      if resource != nil,
        do: resource.user_id,
        else: String.to_integer(conn.params["user_id"] || conn.params["id"])

    cuser != nil && (Abilities.admin?(cuser) || uid == cuser.user_id)
  end

  def allowed?(conn, action, resource) when action in [:edit, :delete, :confirm_delete],
    do: allowed?(conn, :update, resource)

  def allowed?(conn, :show_votes, resource) do
    cuser = conn.assigns[:current_user]
    uid = if resource != nil, do: resource.user_id, else: String.to_integer(conn.params["id"])
    cuser != nil && uid == cuser.user_id
  end

  def allowed?(_, _, _), do: false
end
