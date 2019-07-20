defmodule Cforum.Messages.MessageVersions do
  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Messages.MessageVersion
  alias Cforum.Messages.MessageHelpers
  alias Cforum.Messages.MessageCaching

  def build_version(changeset, message, user) do
    if MessageHelpers.changed?(changeset, message) do
      version =
        message
        |> Ecto.build_assoc(:versions)
        |> MessageVersion.changeset(message, user)

      changeset
      |> Ecto.Changeset.put_assoc(:versions, [version | message.versions])
    else
      changeset
    end
  end

  def get_message_version!(message, id) do
    from(ver in MessageVersion, where: ver.message_id == ^message.message_id and ver.message_version_id == ^id)
    |> Repo.one!()
  end

  def delete_message_version(current_user, version) do
    Cforum.System.audited("destroy", current_user, fn ->
      Repo.delete(version)
    end)
    |> MessageCaching.update_cached_message()
  end
end
