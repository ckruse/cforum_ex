defmodule CforumWeb.Api.V1.Messages.AcceptView do
  use CforumWeb, :view

  alias Cforum.Forums.Messages

  def render("accept.json", %{message: message}) do
    %{accepted: Messages.accepted?(message)}
  end
end
