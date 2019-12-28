defmodule CforumWeb.Users.RegistrationController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.Accounts.Users
  alias Cforum.Accounts.User
  alias Cforum.Helpers

  def new(conn, _params) do
    changeset = User.register_changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"username" => val}) when not is_nil(val) and val != "" do
    raise Cforum.Errors.ForbiddenError, conn: conn
  end

  def create(conn, %{"user" => user_params}) do
    if Helpers.blank?(conn.cookies["cf_sess"]) || !token_valid?(conn),
      do: raise(Cforum.Errors.ForbiddenError, conn: conn)

    case Users.register_user(user_params) do
      {:ok, user} ->
        Cforum.Jobs.UserMailerJob.enqueue(user, "confirm_user")

        conn
        |> put_flash(
          :info,
          gettext("Account successfully created. Please follow the confirmation instructions we send you via mail.")
        )
        |> redirect(to: Path.root_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def confirm(conn, %{"token" => token}) do
    case Users.confirm_user(token) do
      {:ok, user} ->
        conn
        |> Plug.Conn.put_session(:user_id, user.user_id)
        |> Plug.Conn.configure_session(renew: true)
        |> put_flash(:info, gettext("Account successfully confirmed!"))
        |> redirect(to: Path.root_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, gettext("Oops, something went wrong!"))
        |> redirect(to: Path.root_path(conn, :index))
    end
  end

  def allowed?(conn, _, _), do: !Abilities.signed_in?(conn)

  defp token_valid?(conn) do
    case Phoenix.Token.verify(conn, "registering", conn.cookies["cf_sess"], max_age: 600) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
