defmodule CforumWeb.Cite.VoteController do
  use CforumWeb, :controller

  plug(CforumWeb.Plug.AuthorizeAccess)

  alias Cforum.Cites

  def vote(conn, %{"type" => type} = params) when type in ["up", "down"] do
    cite = Cites.get_cite!(params["id"])

    # take back the current vote in all cases; if the type is the same
    # as already voted, we just take it back. If it is different, whe
    # create a new vote with the chosen new value

    only_take_back = Cites.voted?(cite, conn.assigns[:current_user], type)
    Cites.take_back_vote(cite, conn.assigns[:current_user])

    if not only_take_back, do: Cites.vote(cite, conn.assigns[:current_user], type)

    conn
    |> put_flash(:info, gettext("Successfully voted for cite."))
    |> redirect(to: cite_path(conn, :show, cite))
  end
end
