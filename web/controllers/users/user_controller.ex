defmodule Cforum.Users.UserController do
  use Cforum.Web, :controller

  plug Cforum.Plug.AuthorizeAccess, only: [:edit, :update, :confirm_destroy, :destroy, :show_votes]

  alias Cforum.User
  alias Cforum.Thread
  alias Cforum.Message
  alias Cforum.MessageTag
  alias Cforum.Tag
  alias Cforum.Forum
  alias Cforum.Score
  alias Cforum.Vote

  import Ecto.Query, only: [from: 2]

  def index(conn, params) do
    {users, conn} = User
    |> Cforum.Sortable.sort(conn, [:username, :score, :activity, :created_at])

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

    messages_by_months = from(m in Message,
      select: {fragment("DATE_TRUNC('month', created_at) created_at"), count("*")},
      where: m.user_id == ^user.user_id and m.deleted == false,
      group_by: fragment("DATE_TRUNC('month', created_at)"),
      order_by: fragment("DATE_TRUNC('month', created_at)"))
      |> Repo.all

    messages_count = from(m in Message,
      select: count("*"),
      where: m.user_id == ^user.user_id and m.deleted == false)
    |> Repo.one

    last_messages = from(m in Message,
      preload: [:user, :tags, [votes: :voters, thread: :forum]],
      where: m.user_id == ^user.user_id and m.deleted == false and m.forum_id in (^forum_ids),
      order_by: [desc: :created_at],
      limit: 5)
    |> Repo.all
    |> Enum.map(fn(msg) ->
      thread = %Thread{msg.thread | message: msg}
      %Message{msg | thread: thread}
    end)

    tags_cnt = from(mt in MessageTag,
      inner_join: m in Message, on: m.message_id == mt.message_id,
      inner_join: t in Tag, on: mt.tag_id == t.tag_id,
      inner_join: f in Forum, on: f.forum_id == t.forum_id,
      select: {t.slug, t.tag_name, f.slug, f.short_name, count("*")},
      where: m.deleted == false and m.user_id == ^user.user_id and m.forum_id in (^forum_ids),
      group_by: [t.slug, t.tag_name, f.forum_id, f.short_name],
      order_by: fragment("COUNT(*) DESC"),
      limit: 10)
    |> Repo.all

    point_msgs = from(m in Message,
      preload: [:user, :tags, [votes: :voters, thread: :forum]],
      where: m.deleted == false and m.upvotes > 0 and m.user_id == ^user.user_id and m.forum_id in (^forum_ids),
      order_by: [desc: m.upvotes],
      limit: 10)
    |> Repo.all
    |> Enum.map(fn(msg) ->
      thread = %Thread{msg.thread | message: msg}
      %Message{msg | thread: thread}
    end)

    scored_msgs = from(s in scored_msgs_filtered(conn.assigns[:current_user], user, forum_ids),
                       limit: 10)
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
      badges: User.unique_badges(user),
      jabber_id: User.conf(user, "jabber_id"),
      twitter_handle: User.conf(user, "twitter_handle"),
      user_url: User.conf(user, "url"),
      description: User.conf(user, "description"),
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

    paging = scored_msgs_filtered(conn.assigns[:current_user], user, forum_ids)
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
    user = Repo.get!(User, id)
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

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end

  defp scored_msgs_filtered(nil, user, forum_ids) do
    from(s in Score,
      preload: [message: [:user, :tags, [thread: :forum, votes: :voters]],
                vote: [message: [:user, :tags, [thread: :forum, votes: :voters]]]],
      left_join: m1 in Message, on: m1.message_id == s.message_id,
      left_join: v in Vote, on: s.vote_id == v.vote_id,
      left_join: m2 in Message, on: v.message_id == m2.message_id,
      where: s.user_id == ^user.user_id,
      where: is_nil(m1.message_id) or m1.forum_id in (^forum_ids),
      where: is_nil(m2.message_id) or m2.forum_id in (^forum_ids),
      where: is_nil(m1.message_id) or m1.deleted == false,
      where: is_nil(m2.message_id) or m2.deleted == false,
      where: m2.user_id == ^user.user_id,
      order_by: [desc: :created_at])
  end

  defp scored_msgs_filtered(%User{user_id: cuid}, user = %User{user_id: uid}, forum_ids) when cuid == uid do
    from(s in Score,
      preload: [message: [:user, :tags, [thread: :forum, votes: :voters]],
                vote: [message: [:user, :tags, [thread: :forum, votes: :voters]]]],
      left_join: m1 in Message, on: m1.message_id == s.message_id,
      left_join: v in Vote, on: s.vote_id == v.vote_id,
      left_join: m2 in Message, on: v.message_id == m2.message_id,
      where: s.user_id == ^user.user_id,
      where: is_nil(m1.message_id) or m1.forum_id in (^forum_ids),
      where: is_nil(m2.message_id) or m2.forum_id in (^forum_ids),
      where: is_nil(m1.message_id) or m1.deleted == false,
      where: is_nil(m2.message_id) or m2.deleted == false,
      order_by: [desc: :created_at])
  end
  defp scored_msgs_filtered(_, user, forum_ids), do: scored_msgs_filtered(nil, user, forum_ids)
end
