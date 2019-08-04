defmodule CforumWeb.Events.AttendeeController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.Events
  alias Cforum.Events.{Attendee, Attendees}
  alias Cforum.Helpers

  def new(conn, _params) do
    changeset = Attendees.change_attendee(%Attendee{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"attendee" => attendee_params}) do
    case Attendees.create_attendee(conn.assigns.event, conn.assigns.current_user, attendee_params) do
      {:ok, _attendee} ->
        conn
        |> put_flash(:info, gettext("You registered successfully."))
        |> redirect(to: Path.event_path(conn, :show, conn.assigns.event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    changeset = Attendees.change_attendee(conn.assigns.attendee)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"attendee" => attendee_params}) do
    case Attendees.update_attendee(conn.assigns.current_user, conn.assigns.attendee, attendee_params) do
      {:ok, _attendee} ->
        conn
        |> put_flash(:info, gettext("Your registration was successfully updated."))
        |> redirect(to: Path.event_path(conn, :show, conn.assigns.event))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    {:ok, _attendee} = Attendees.delete_attendee(conn.assigns.current_user, conn.assigns.attendee)

    conn
    |> put_flash(:info, gettext("Attendee deleted successfully."))
    |> redirect(to: Path.event_path(conn, :show, conn.assigns.event))
  end

  def load_resource(conn) do
    event = Events.get_event!(conn.params["event_id"])

    attendee =
      if Phoenix.Controller.action_name(conn) in [:edit, :update, :delete],
        do: Attendees.get_attendee!(event, conn.params["id"]),
        else: nil

    conn
    |> Plug.Conn.assign(:event, event)
    |> Plug.Conn.assign(:attendee, attendee)
  end

  def allowed?(conn, action, _) when action in [:new, :create] do
    base = Helpers.present?(conn.assigns[:event]) && Events.open?(conn.assigns.event)

    if Abilities.signed_in?(conn) do
      base && Enum.find_value(conn.assigns.event.attendees, &(&1.user_id == conn.assigns.current_user.user_id)) == nil
    else
      base
    end
  end

  def allowed?(conn, _, attendee) do
    attendee = attendee || conn.assigns[:attendee]

    Abilities.admin?(conn) ||
      (Abilities.signed_in?(conn) && Helpers.present?(attendee) &&
         attendee.user_id == conn.assigns[:current_user].user_id)
  end
end
