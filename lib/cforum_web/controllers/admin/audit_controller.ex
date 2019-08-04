defmodule CforumWeb.Admin.AuditController do
  use CforumWeb, :controller

  alias Cforum.Abilities
  alias Cforum.System

  alias CforumWeb.Paginator

  def index(conn, params) do
    changeset =
      {%{
         from: Timex.today(),
         to: Timex.today(),
         objects: []
       }, %{from: :date, to: :date, objects: {:array, :string}}}
      |> Ecto.Changeset.cast(params["search"] || %{}, [:from, :to, :objects])

    count = System.count_auditing(changeset)
    paging = Paginator.paginate(count, page: params["p"])
    audit_entries = System.list_auditing(changeset, limit: paging.params)

    render(conn, "index.html", paging: paging, audit_entries: audit_entries, changeset: changeset)
  end

  def allowed?(conn, _, _), do: Abilities.admin?(conn)
end
