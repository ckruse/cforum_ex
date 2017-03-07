defmodule Cforum.Helpers do
  use Phoenix.HTML

  def signed_in?(conn) do
    conn.assigns[:current_user] != nil
  end

  def blank?(nil), do: true
  def blank?(""), do: true
  def blank?(0), do: true
  def blank?(false), do: true
  def blank?([]), do: true
  def blank?(%{}), do: true
  def blank?(_), do: false

  def date_format(conn, name \\ "date_format_default") do
    val = Cforum.ConfigManager.uconf(conn, name)
    if blank?(val), do: "%d.%m.%Y %H:%M", else: val
  end
end
