defmodule Cforum.Accounts.Setting do
  use CforumWeb, :model

  @primary_key {:setting_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :setting_id}

  schema "settings" do
    field(:options, :map)
    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
    belongs_to(:user, Cforum.Accounts.User, references: :user_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:options, :forum_id, :user_id])
    |> remove_default_option_values()
    |> validate_required([:options])
    |> unique_constraint(:forum_id)
  end

  defp remove_default_option_values(%Ecto.Changeset{valid?: true} = changeset) do
    case Ecto.Changeset.get_change(changeset, :options) do
      nil ->
        changeset

      options ->
        options = Enum.reduce(options, %{}, &defaults_reduce/2)
        Ecto.Changeset.put_change(changeset, :options, options)
    end
  end

  defp remove_default_option_values(changeset), do: changeset

  defp defaults_reduce({_key, "_DEFAULT_"}, acc), do: acc
  defp defaults_reduce({key, value}, acc), do: Map.put(acc, key, value)
end

defimpl Cforum.System.AuditingProtocol, for: Cforum.Accounts.Setting do
  def audit_json(setting) do
    setting
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user, :forum])
  end
end
