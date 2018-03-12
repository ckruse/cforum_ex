defmodule CforumWeb.MailView do
  use CforumWeb, :view

  alias Cforum.Accounts.PrivMessages

  def page_heading(action, assigns), do: page_title(action, assigns)

  def page_title(:index, _), do: gettext("mails")
  def page_title(:new, _), do: gettext("new mail")

  def page_title(:show, assigns),
    do: gettext("mail from %{partner}", partner: PrivMessages.partner_name(assigns[:priv_message]))

  def body_id(:index, _), do: "mail-index"
  def body_id(:show, _), do: "mail-show"
  def body_id(:new, _), do: "mail-new"

  def body_classes(:index, _), do: "mail index"
  def body_classes(:show, _), do: "mail show"
  def body_classes(:new, _), do: "mail new"
end
