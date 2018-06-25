defmodule CforumWeb.Admin.AuditView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("audit log")
  def page_title(:show, _), do: gettext("audit log")

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "admin-audit-index"
  def body_id(:show), do: "admin-audit-show"
  def body_classes(:index, _), do: "admin audit index"
  def body_classes(:show, _), do: "admin audit show"

  def url_params(changeset) do
    [
      search: [
        from: Timex.lformat!(Ecto.Changeset.get_field(changeset, :from), "{RFC3339z}", "en"),
        to: Timex.lformat!(Ecto.Changeset.get_field(changeset, :to), "{RFC3339z}", "en")
      ]
    ]
  end

  def is_object_checked?(changeset, type) do
    objects = Ecto.Changeset.get_field(changeset, :objects)
    Enum.find(objects, &(&1 == type)) != nil
  end

  alias Cforum.System.Auditing
  import CforumWeb.AuditingViewL10n

  def render_object(conn, %Auditing{relation: rel} = entry), do: render("#{rel}.html", conn: conn, entry: entry)
end
