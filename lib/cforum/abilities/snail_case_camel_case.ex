defmodule Cforum.Abilities.SnailCaseCamelCase do
  def to_camel_case(s) do
    s
    |> String.capitalize()
    |> upcase_after_dash()
    |> upcase_after_slash()
  end

  defp upcase_after_dash(s),
    do: Regex.replace(~r/_(.)/, s, fn _, c -> String.upcase(c) end)

  defp upcase_after_slash(s),
    do: Regex.replace(~r{/(.)}, s, fn _, c -> "." <> String.upcase(c) end)
end
