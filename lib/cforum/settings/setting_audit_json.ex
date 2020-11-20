defmodule Cforum.Settings.SettingAuditJson do
  def to_json(setting) do
    setting
    |> Map.from_struct()
    |> Map.drop([:__meta__, :user, :forum])
  end
end
