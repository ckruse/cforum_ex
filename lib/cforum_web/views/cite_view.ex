defmodule CforumWeb.CiteView do
  use CforumWeb, :view

  alias Cforum.Cites

  def page_title(:index, _), do: gettext("cites")
  def page_title(:index_voting, _), do: gettext("vote for cites")
  def page_title(:show, assigns), do: gettext("cite %{id}", id: assigns[:cite].cite_id)
  def page_title(action, _) when action in [:new, :create], do: gettext("suggest new cite")
  def page_title(action, %{cite: c}) when action in [:edit, :update], do: gettext("edit cite #%{id}", id: c.cite_id)

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "cites-index"
  def body_id(:index_voting, _), do: "cites-votes-index"
  def body_id(:show, _), do: "cites-show"
  def body_id(action, _) when action in [:new, :create], do: "cites-new"
  def body_id(action, _) when action in [:edit, :update], do: "cites-edit"

  def body_classes(:index, _), do: "cites index"
  def body_classes(:index_voting, _), do: "cites votes index"
  def body_classes(:show, _), do: "cites show"
  def body_classes(action, _) when action in [:new, :create], do: "cites new"
  def body_classes(action, _) when action in [:edit, :update], do: "cites edit"

  def link_to_url?(conn, cite),
    do: !blank?(cite.url) && (blank?(cite.message_id) || may?(conn, "message", :show, cite.message))

  def url_link_title(cite), do: if(blank?(cite.message_id), do: cite.url, else: cite.message.subject)

  def votable?(conn, cite), do: signed_in?(conn) && !cite.archived && !blank?(cite.cite_id)

  def path_args(conn) do
    if action_name(conn) == :index, do: [conn, :index], else: [conn, :index_voting]
  end
end
