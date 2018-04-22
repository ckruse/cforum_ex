defmodule Cforum.Abilities do
  @moduledoc """
  This module defines all access rights for users in our forum system
  """

  require Logger
  import Cforum.Abilities.Helpers

  @doc """
  Returns `true` if the user may access the given path, `false` otherwise

  ## Parameters

  - `conn`: the connection struct of the current request
  - `path`: the path to check if the user has access to, e.g. `"users/user"`
  - `action`: the action on the path, e.g. `:index`
  - `args`: additional arguments, e.g. the resource in question
  """
  def may?(conn, path, action \\ :index, args \\ nil)

  use Cforum.Abilities.Forum
  use Cforum.Abilities.Thread
  use Cforum.Abilities.Notification
  use Cforum.Abilities.Mail
  use Cforum.Abilities.Users.User
  use Cforum.Abilities.Users.Password
  use Cforum.Abilities.Users.Session
  use Cforum.Abilities.Users.Registration
  use Cforum.Abilities.Cite
  use Cforum.Abilities.Message
  use Cforum.Abilities.Badge

  use Cforum.Abilities.Admin
  use Cforum.Abilities.V1.Api

  def may?(_conn, path, action, _) do
    Logger.debug(fn -> "--- CAUTION: no ability defined for path #{path} and action #{action}" end)
    false
  end
end
