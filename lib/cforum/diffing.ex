defmodule Cforum.Diffing do
  def diff(version1, version2) do
    String.myers_difference(version1, version2)
    |> to_html()
  end

  defp to_html([{:eq, val} | tail]), do: [val | to_html(tail)]
  defp to_html([{:ins, val} | tail]), do: [[{:safe, "<ins>"}, val, {:safe, "</ins>"}] | to_html(tail)]
  defp to_html([{:del, val} | tail]), do: [[{:safe, "<del>"}, val, {:safe, "</del>"}] | to_html(tail)]
  defp to_html([]), do: []
end
