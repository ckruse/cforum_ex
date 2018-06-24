defprotocol Cforum.System.AuditingProtocol do
  @fallback_to_any true
  def audit_json(object)
end

defimpl Cforum.System.AuditingProtocol, for: Any do
  def audit_json(object), do: object
end
