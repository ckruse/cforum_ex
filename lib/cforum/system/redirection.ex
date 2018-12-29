defmodule Cforum.System.Redirection do
  use CforumWeb, :model

  @primary_key {:redirection_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :redirection_id}

  schema "redirections" do
    field(:comment, :string)
    field(:destination, :string)
    field(:http_status, :integer)
    field(:path, :string)
  end

  @doc false
  def changeset(redirection, attrs) do
    redirection
    |> cast(attrs, [:path, :destination, :http_status, :comment])
    |> validate_required([:path, :destination, :http_status])
    |> unique_constraint(:path, name: :redirections_path_key)
  end
end
