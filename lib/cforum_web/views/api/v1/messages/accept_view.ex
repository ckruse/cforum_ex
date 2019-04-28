defmodule CforumWeb.Api.V1.Messages.AcceptView do
  use CforumWeb, :view

  alias Cforum.Messages.MessageHelpers

  def render("accept.json", %{message: message}) do
    %{accepted: MessageHelpers.accepted?(message)}
  end
end
