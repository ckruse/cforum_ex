defmodule CforumWeb.Messages.OpenCloseVoteController do
  use CforumWeb, :controller

  def allowed?(_, _, _), do: false
end
