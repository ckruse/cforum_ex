defmodule Cforum.Plurals do
  @behaviour Gettext.Plural

  def nplurals("de"), do: 3
  def nplurals(locale), do: Gettext.Plural.nplurals(locale)

  def plural("de", 0), do: 0
  def plural("de", 1), do: 1
  def plural("de", _), do: 2

  def plural(locale, n), do: Gettext.Plural.plural(locale, n)
end
