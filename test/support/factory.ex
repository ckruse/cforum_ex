defmodule Cforum.Factory do
  use ExMachina.Ecto, repo: Cforum.Repo
  use Cforum.UserFactory
end
