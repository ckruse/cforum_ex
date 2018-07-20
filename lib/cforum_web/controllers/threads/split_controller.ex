defmodule CforumWeb.Threads.SplitController do
  use CforumWeb, :controller

  def allowed?(_, _, _), do: false
end
