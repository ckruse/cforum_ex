defmodule CforumWeb.Admin.AuditView do
  use CforumWeb, :view

  alias CforumWeb.Paginator
  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def page_title(:index, _), do: gettext("audit log")
  def page_title(:show, _), do: gettext("audit log")

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "admin-audit-index"
  def body_id(:show), do: "admin-audit-show"
  def body_classes(:index, _), do: "admin audit index"
  def body_classes(:show, _), do: "admin audit show"

  def url_params(changeset) do
    [
      search:
        [
          from: Timex.lformat!(Ecto.Changeset.get_field(changeset, :from), "{YYYY}-{0M}-{0D}", "en"),
          to: Timex.lformat!(Ecto.Changeset.get_field(changeset, :to), "{YYYY}-{0M}-{0D}", "en")
        ]
        |> add_objects(Ecto.Changeset.get_field(changeset, :objects))
    ]
  end

  defp add_objects(opts, objects) when is_nil(objects) or objects == [], do: opts
  defp add_objects(opts, objects), do: Keyword.put(opts, :objects, objects)

  def is_object_checked?(changeset, type) do
    objects = Ecto.Changeset.get_field(changeset, :objects)
    Enum.find(objects, &(&1 == type)) != nil
  end

  def score_username(uid) do
    user = Cforum.Accounts.Users.get_user(uid)
    if user == nil, do: gettext("(unknown)"), else: user.username
  end

  alias Cforum.System.Auditing
  import CforumWeb.AuditingViewL10n

  def render_object(conn, %Auditing{relation: rel} = entry), do: render("#{rel}.html", conn: conn, entry: entry)
end
