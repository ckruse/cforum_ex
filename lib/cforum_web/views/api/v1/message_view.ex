defmodule CforumWeb.Api.V1.MessageView do
  use CforumWeb, :view

  import Ecto.Changeset, only: [get_field: 2]

  def render("quote.json", %{changeset: changeset}) do
    %{
      subject: get_field(changeset, :subject),
      author: get_field(changeset, :author),
      email: get_field(changeset, :email),
      homepage: get_field(changeset, :homepage),
      problematic_site: get_field(changeset, :problematic_site),
      content: get_field(changeset, :content) |> IO.iodata_to_binary(),
      tags: Enum.map(get_field(changeset, :tags), & &1.tag_name)
    }
  end
end
