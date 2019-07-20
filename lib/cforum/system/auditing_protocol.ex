defprotocol Cforum.System.AuditingProtocol do
  @fallback_to_any true
  def audit_json(object)
end

defimpl Cforum.System.AuditingProtocol, for: List do
  def audit_json(list), do: Enum.map(list, &Cforum.System.AuditingProtocol.audit_json(&1))
end

defimpl Cforum.System.AuditingProtocol, for: Any do
  def audit_json(object), do: object
end

defimpl Cforum.System.AuditingProtocol, for: Ecto.Association.NotLoaded do
  def audit_json(_), do: nil
end
