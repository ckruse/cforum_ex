defmodule CforumWeb.MailController do
  use CforumWeb, :controller

  alias Cforum.Accounts.PrivMessage

  def index(conn, _params) do
    mails = Repo.all(PrivMessage)
    render(conn, "index.html", mails: mails)
  end

  def new(conn, _params) do
    changeset = PrivMessage.changeset(%PrivMessage{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"priv_message" => priv_message_params}) do
    changeset = PrivMessage.changeset(%PrivMessage{}, priv_message_params)

    case Repo.insert(changeset) do
      {:ok, _priv_message} ->
        conn
        |> put_flash(:info, "PrivMessage created successfully.")
        |> redirect(to: mail_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    priv_message = Repo.get!(PrivMessage, id)
    render(conn, "show.html", priv_message: priv_message)
  end

  def edit(conn, %{"id" => id}) do
    priv_message = Repo.get!(PrivMessage, id)
    changeset = PrivMessage.changeset(priv_message)
    render(conn, "edit.html", priv_message: priv_message, changeset: changeset)
  end

  def update(conn, %{"id" => id, "priv_message" => priv_message_params}) do
    priv_message = Repo.get!(PrivMessage, id)
    changeset = PrivMessage.changeset(priv_message, priv_message_params)

    case Repo.update(changeset) do
      {:ok, priv_message} ->
        conn
        |> put_flash(:info, "PrivMessage updated successfully.")
        |> redirect(to: mail_path(conn, :show, priv_message))

      {:error, changeset} ->
        render(conn, "edit.html", priv_message: priv_message, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    priv_message = Repo.get!(PrivMessage, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(priv_message)

    conn
    |> put_flash(:info, "PrivMessage deleted successfully.")
    |> redirect(to: mail_path(conn, :index))
  end
end
