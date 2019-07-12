defmodule CforumWeb.Cite.VoteController do
  use CforumWeb, :controller

  alias Cforum.Cites

  def vote(conn, %{"type" => type}) when type in ["up", "down"] do
    # take back the current vote in all cases; if the type is the same
    # as already voted, we just take it back. If it is different, whe
    # create a new vote with the chosen new value

    only_take_back = Cites.voted?(conn.assigns.cite, conn.assigns[:current_user], type)
    Cites.take_back_vote(conn.assigns.cite, conn.assigns[:current_user])

    if not only_take_back,
      do: Cites.vote(conn.assigns.cite, conn.assigns[:current_user], type)

    conn
    |> put_flash(:info, gettext("Successfully voted for cite."))
    |> redirect(to: Path.cite_path(conn, :show, conn.assigns.cite))
  end

  def load_resource(conn), do: Plug.Conn.assign(conn, :cite, Cites.get_cite!(conn.params["id"]))
  def allowed?(conn, _, _), do: Abilities.signed_in?(conn) && conn.assigns.cite.archived == false
end
