defimpl Cforum.System.AuditingProtocol, for: Cforum.Media.Image do
  def audit_json(img) do
    img
    |> Map.from_struct()
    |> Map.drop([:__meta__, :owner])
  end
end
