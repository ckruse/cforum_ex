defmodule Cforum.Settings.Setting do
  use CforumWeb, :model

  alias Cforum.Helpers

  @primary_key {:setting_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :setting_id}

  schema "settings" do
    field(:options, :map)
    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
    belongs_to(:user, Cforum.Users.User, references: :user_id)
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
    |> validate_urls()
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

  defp validate_urls(changeset) do
    with %{} = options <- Ecto.Changeset.get_change(changeset, :options),
         :ok <- check_url(options["url"]) do
      changeset
    else
      nil -> changeset
      {:error, msg} -> add_error(changeset, :options_url, msg)
    end
  end

  defp check_url(url) when is_binary(url) and url != "", do: Helpers.check_url(url)
  defp check_url(_), do: :ok
end
