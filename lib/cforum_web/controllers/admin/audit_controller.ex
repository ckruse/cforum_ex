defmodule CforumWeb.Admin.AuditController do
  use CforumWeb, :controller

  alias Cforum.System

  def index(conn, params) do
    changeset =
      {%{
         from: Timex.beginning_of_day(NaiveDateTime.utc_now()),
         to: Timex.end_of_day(NaiveDateTime.utc_now()),
         objects: []
       }, %{from: Timex.Ecto.DateTimeWithTimezone, to: Timex.Ecto.DateTimeWithTimezone, objects: {:array, :string}}}
      |> Ecto.Changeset.cast(params["search"] || %{}, [:from, :to, :objects])

    count = System.count_auditing(changeset)
    paging = paginate(count, page: params["p"])
    audit_entries = System.list_auditing(changeset, limit: paging.params)

    render(conn, "index.html", paging: paging, audit_entries: audit_entries, changeset: changeset)
  end
end
