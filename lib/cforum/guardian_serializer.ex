defmodule Cforum.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias Cforum.Repo
  alias Cforum.User

  def for_token(user = %User{}), do: { :ok, "User:#{user.user_id}" }
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("User:" <> id), do: { :ok, Repo.get(User, id) }
  def from_token(_), do: { :error, "Unknown resource type" }
end
