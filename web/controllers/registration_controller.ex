defmodule Cforum.Users.RegistrationController do
  use Cforum.Web, :controller

  import Ecto.Changeset

  alias Cforum.User
  alias Phoenix.Token

  def new(conn, _params) do
    changeset = User.register_changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.register_changeset(%User{}, user_params)
    |> put_change(:confirmation_token, generate_confirmation_token(user_params["username"]))
    |> put_change(:active, true)

    {:changes, password} = fetch_field(changeset, :password)
    {:changes, password_confirmation} = fetch_field(changeset, :password_confirmation)

    changeset = if password != password_confirmation do
      add_error(changeset, :password, gettext("password and password confirmation don't match"))
    else
      put_change(changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
    end

    case Repo.insert(changeset) do
      {:ok, user} ->
        Cforum.UserMailer.confirmation_mail(user) |> Cforum.Mailer.deliver_later

        conn
        |> put_flash(:info, gettext("Account successfully created. Please follow the confirmation instructions we send you via mail."))
        |> redirect(to: forum_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def confirm(conn, %{"token" => token}) do
    user = Repo.get_by!(User, confirmation_token: token)
    changeset = Ecto.Changeset.change user, confirmed_at: Ecto.DateTime.utc

    case Repo.update changeset do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("Account successfully confirmed!"))
        |> Cforum.Auth.login(user)
        |> redirect(to: forum_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, gettext("Oops, something went wrong!"))
        |> redirect(to: forum_path(conn, :index))
    end
  end

  def generate_confirmation_token(nil), do: nil
  def generate_confirmation_token(username) do
    Token.sign(Cforum.Endpoint, "user", username)
  end
end
