defmodule CforumWeb.MailView do
  use CforumWeb, :view

  alias Cforum.Helpers

  alias CforumWeb.Paginator
  alias CforumWeb.Sortable
  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  alias Cforum.Accounts.PrivMessages

  def page_heading(action, assigns), do: page_title(action, assigns)

  def page_title(:index, _), do: gettext("mails")
  def page_title(action, _) when action in [:new, :create], do: gettext("new mail")

  def page_title(:show, assigns),
    do: gettext("mail from %{partner}", partner: assigns[:pm_thread] |> List.first() |> PrivMessages.partner_name())

  def body_id(:index, _), do: "mail-index"
  def body_id(:show, _), do: "mail-show"
  def body_id(action, _) when action in [:new, :create], do: "mail-new"

  def body_classes(:index, _), do: "mail index"
  def body_classes(:show, _), do: "mail show"
  def body_classes(action, _) when action in [:new, :create], do: "mail new"

  def url_params(conn) do
    if Cforum.Helpers.present?(conn.params["author"]),
      do: [author: conn.params["author"]],
      else: nil
  end
end
