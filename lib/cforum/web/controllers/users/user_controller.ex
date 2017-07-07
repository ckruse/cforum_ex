defmodule Cforum.Web.Users.UserController do
  use Cforum.Web, :controller

  plug Cforum.Plug.AuthorizeAccess, only: [:edit, :update, :confirm_delete, :delete, :show_votes]

  alias Cforum.Accounts.User
  alias Cforum.Accounts.Users
  alias Cforum.Accounts.Score
  alias Cforum.Forums.Messages
  alias Cforum.Forums.Thread
  alias Cforum.Forums.Message
  alias Cforum.Forums.MessageTag
  alias Cforum.Forums.Tag
  alias Cforum.Forums.Forum
  alias Cforum.Forums.Vote

  def index(conn, params) do
    {users, conn} = Cforum.Sortable.sort(User, conn, [:username, :score, :activity, :created_at])

    paging = users
    |> paginate(page: params["p"])

    render(conn, "index.html", users: paging.entries, paging: paging)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = from(u in User,
      preload: [:settings, [badges_users: :badge]],
      where: u.user_id == ^id)
    |> Repo.one!

    forum_ids = Enum.map(conn.assigns[:visible_forums], &(&1.forum_id))
    messages_count = Messages.count_messages_for_user(user)
    messages_by_months = Messages.count_messages_for_user_by_month(user)
    tags_cnt = Messages.count_messages_per_tag_for_user(user, forum_ids)

    last_messages = Messages.list_last_messages_for_user(user, forum_ids)
    |> Enum.map(fn(msg) ->
      thread = %Thread{msg.thread | message: msg}
      %Message{msg | thread: thread}
    end)

    point_msgs = Messages.list_best_scored_messages_for_user(user, forum_ids)
    |> Enum.map(fn(msg) ->
      thread = %Thread{msg.thread | message: msg}
      %Message{msg | thread: thread}
    end)

    scored_msgs = Messages.list_scored_msgs_for_user_in_perspective(conn.assigns[:current_user], user, forum_ids, 10)
    |> Repo.all
    |> Enum.reduce({%{}, 0}, fn(score, {msgs, fake_id}) ->
        m = case score.vote do
              nil ->
                score.message
              v ->
                v.message
            end

        {new_fid, id} = if m == nil,
          do: {fake_id + 1, "fake-#{fake_id}"},
          else: {fake_id, m.message_id}

        {Map.update(msgs, id, [score], fn(scores) -> [score | scores] end),
          new_fid}
    end)
    |> (fn({msgs, _}) -> msgs end).()
    |> Map.values
    |> Enum.sort(fn(a, b) ->
      List.last(a).created_at >= List.last(b).created_at
    end)

    render(conn, "show.html",
      user: user,
      messages_by_months: messages_by_months,
      messages_count: messages_count,
      last_messages: last_messages,
      tags_cnt: tags_cnt,
      point_msgs: point_msgs,
      badges: Users.unique_badges(user),
      jabber_id: Users.conf(user, "jabber_id"),
      twitter_handle: Users.conf(user, "twitter_handle"),
      user_url: Users.conf(user, "url"),
      description: Users.conf(user, "description"),
      scored_msgs: scored_msgs)
  end

  def show_messages(conn, %{"id" => id} = params) do
    user = Repo.get!(User, id)
    forum_ids = Enum.map(conn.assigns[:visible_forums], &(&1.forum_id))

    paging = from(m in Message,
      preload: [:user, :tags, [votes: :voters, thread: :forum]],
      where: m.user_id == ^user.user_id and m.deleted == false and m.forum_id in (^forum_ids),
      order_by: [desc: :created_at])
    |> paginate(page: params["p"])

    messages = Enum.map(paging.entries, fn(msg) ->
      thread = %Thread{msg.thread | message: msg}
      %Message{msg | thread: thread}
    end)

    render(conn, "show_messages.html",
           user: user,
           messages: messages,
           paging: paging)
  end

  def show_scores(conn, %{"id" => id} = params) do
    user = Repo.get!(User, id)
    forum_ids = Enum.map(conn.assigns[:visible_forums], &(&1.forum_id))
    
    paging = Messages.list_scored_msgs_for_user_in_perspective(conn.assigns[:current_user], user, forum_ids)
    |> paginate(page: params["p"])
    
    render(conn, "show_scores.html",
           user: user,
           paging: paging,
           scores: paging.entries)
  end

  def show_votes(conn, %{"id" => id} = params) do
    user = Repo.get!(User, id)
    forum_ids = Enum.map(conn.assigns[:visible_forums], &(&1.forum_id))

    paging = from(v in Vote,
      inner_join: m in Message, on: m.message_id == v.message_id,
      preload: [:score, message: [:user, :tags,
                                  [thread: :forum, votes: :voters]]],
      where: v.user_id == ^user.user_id,
      where: m.forum_id in (^forum_ids) and m.deleted == false,
      order_by: [desc: m.created_at])
    |> paginate(page: params["p"])

    render(conn, "show_votes.html",
      user: user,
      paging: paging,
      votes: paging.entries)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id) |> Repo.preload(:settings)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def confirm_delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "confirm_delete.html", user: user)
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end


end
