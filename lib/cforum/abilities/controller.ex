defmodule Cforum.Abilities.Controller do
  @moduledoc """
  Callback structure for cforum controllers
  """

  @callback allowed?(Plug.Conn.t(), atom(), any()) :: boolean()
end
