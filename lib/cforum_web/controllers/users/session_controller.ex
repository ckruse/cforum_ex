defmodule CforumWeb.Users.SessionController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.Users
  alias Cforum.Users.User
  alias Cforum.Messages
  alias Cforum.Messages.Message
  alias Cforum.Threads
  alias Cforum.Threads.Thread

  alias CforumWeb.Views.ViewHelpers.Path

  def new(conn, _params) do
    changeset = User.login_changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"login" => user, "password" => pass, "remember_me" => remember}}) do
    case Users.authenticate_user(user, pass) do
      {:ok, user} ->
        conn =
          case remember do
            "true" ->
              token = Phoenix.Token.sign(CforumWeb.Endpoint, "user", user.user_id)

              conn
              |> put_resp_cookie("remember_me", token,
                max_age: 30 * 24 * 60 * 60,
                http_only: true,
                domain: Application.get_env(:cforum, :cookie_domain)
              )

            _ ->
              conn
          end

        conn
        |> put_session(:user_id, user.user_id)
        |> configure_session(renew: true)
        |> put_flash(:info, gettext("You logged in successfully"))
        |> redirect(to: return_url(conn))

      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("Username or password wrong"))
        |> render("new.html", changeset: changeset)
    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, gettext("You logged out successfully"))
    |> delete_resp_cookie("remember_me")
    |> redirect(to: Path.root_path(conn, :index))
  end

  def allowed?(conn, :delete, _), do: Abilities.signed_in?(conn)
  def allowed?(conn, action, _) when action in [:new, :create], do: !Abilities.signed_in?(conn)
  def allowed?(_, _, _), do: false

  defp return_url(conn) do
    with mid when not is_nil(mid) and mid != "" <- conn.params["return_to"],
         true <- Regex.match?(~r/^\d+$/, mid),
         %Message{} = msg <- Messages.get_message(mid),
         %Thread{} = thread <- Threads.get_thread(msg.thread_id) do
      if String.starts_with?(conn.host, "blog."),
        do: Path.blog_thread_path(conn, :show, thread),
        else: Path.message_path(conn, :show, thread, msg)
    else
      _ -> Path.root_path(conn, :index)
    end
  end
end
