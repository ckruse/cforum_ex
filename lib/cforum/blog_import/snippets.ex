defmodule Cforum.BlogImport.Snippets do
  alias Cforum.Media

  defp create_image(url) do
    response = Tesla.get!(url)
    tmpfile = Briefly.create!()
    File.write!(tmpfile, response.body)

    {:ok, img} =
      Media.create_image(nil, %Plug.Upload{
        path: tmpfile,
        content_type: MIME.from_path(url),
        filename: Regex.replace(~r(.*/), url, "")
      })

    img
  end

  defp safe_html(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end

  defp images_as_html(images) do
    Enum.map(images, fn {url, text} ->
      img = create_image(url)
      path = CforumWeb.Views.ViewHelpers.Path.blog_image_url(CforumWeb.Endpoint, :show, img, %{"size" => "medium"})
      full_path = CforumWeb.Views.ViewHelpers.Path.blog_image_url(CforumWeb.Endpoint, :show, img)
      html = if text, do: safe_html(text), else: ""

      """
      <figure role="group">
        <a href="#{full_path}"><img src="#{path}" alt="#{html}"></a>
        <figcaption>#{text}</figcaption>
      </figure>
      """
      |> String.replace("<figcaption></figcaption>", "")
    end)
  end

  def gallery("[gallery ids=\"1401,1402,1403,1404,1405,1406,1407,1408,1409,1410,1411,1414\"]") do
    images = [
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_2.jpg",
       "Potsdamer Platz im „Festival of Lights“ 2017"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_3.jpg", "Sony-Center"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_4.jpg",
       "US-Botschaft im „Festival of Lights“ 2017"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_5.jpg",
       "Brandenburger Tor im „Festival of Lights“ 2017"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_6.jpg",
       "Brandenburger Tor im „Festival of Lights“ 2017"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_7.jpg",
       "Staatsoper im im „Festival of Lights“ 2017"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_8.jpg",
       "Humboldt-Universität im „Festival of Lights“ 2017"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_9.jpg", nil},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_10.jpg",
       "Marienkriche und Fernsehturm im „Festival of Lights“ 2017"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_11.jpg",
       "Fernsehturm im „Festival of Lights“ 2017"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_12.jpg",
       "Fernsehturm im „Festival of Lights“ 2017"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/05/20171006_15.jpg",
       "Hackesche Höfe im „Festival of Lights“ 2017"}
    ]

    parts = images_as_html(images)

    "<figure role=\"group\" class=\"gallery three-cols\">#{parts}</figure>"
  end

  def gallery("[gallery columns=\"1\" size=\"medium\" ids=\"1571,1572,1575,1573,1574,1576\"]") do
    images = [
      {"https://blog.selfhtml.org/wp-content/uploads/2018/09/2018-Do-4.jpg", "Kultur: Computer & Konsolen"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/09/2018-Do-5.jpg",
       "TS, der noch jedes Byte persönlich kannte"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/09/2018-DO-8.jpg", "„Die Diskette müsste jetzt doch laden?“"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/09/2018-DO-6.jpg", "In einem Land vor unserer Zeit"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/09/2018-Do-7.jpg", "Fachsimpeleien"},
      {"https://blog.selfhtml.org/wp-content/uploads/2018/09/2018-DO-9.jpg",
       "„Wenn’s im Forum heißhergeht, könnte man sich doch auch bei einem Spiel entspannen!“"}
    ]

    parts = images_as_html(images)

    "<figure role=\"group\" class=\"gallery three-cols\">#{parts}</figure>"
  end

  def gallery("[gallery columns=\"4\" size=\"medium\" ids=\"1780,1781,1782,1783\"]") do
    images = [
      {"https://blog.selfhtml.org/wp-content/uploads/2019/07/veranstaltungsort.jpg", "Veranstaltungsort"},
      {"https://blog.selfhtml.org/wp-content/uploads/2019/07/berlin.jpg", "ich in Berlin"},
      {"https://blog.selfhtml.org/wp-content/uploads/2019/07/keynote.jpg", "Keynote"},
      {"https://blog.selfhtml.org/wp-content/uploads/2019/07/maritim.jpg", "Maritim Hotel"}
    ]

    parts = images_as_html(images)

    "<figure role=\"group\" class=\"gallery two-cols\">#{parts}</figure>"
  end

  def gallery("[gallery columns=\"4\" ids=\"1969,1967,1968,1970\"]") do
    images = [
      {"https://blog.selfhtml.org/wp-content/uploads/2020/10/IMG_0716.jpg", nil},
      {"https://blog.selfhtml.org/wp-content/uploads/2020/10/IMG_0714.jpg", nil},
      {"https://blog.selfhtml.org/wp-content/uploads/2020/10/IMG_0713.jpg", nil},
      {"https://blog.selfhtml.org/wp-content/uploads/2020/10/IMG_0718.jpg", nil}
    ]

    parts = images_as_html(images)

    "<figure role=\"group\" class=\"gallery two-cols\">#{parts}</figure>"
  end

  def caption(text) do
    [cap] = Regex.run(~r/\[caption[^\]]+\]/, text)

    caption =
      Regex.run(~r/<img[^>]+>(?:<\/a>)?(.*)/s, text, capture: :all_but_first)
      |> List.first()
      |> String.replace(~r/\[\/caption\]/, "")

    retval =
      text
      |> String.slice(String.length(cap)..-(String.length(caption) + 10))
      |> String.replace(~r/\[\/caption\]/, "")

    attrs = parse_key_value(cap)

    class =
      if attrs["align"],
        do: " class=\"#{attrs["align"]}\"",
        else: ""

    styles =
      Map.drop(attrs, ["id", "align"])
      |> Enum.map(fn {k, v} -> "#{k}: #{v};" end)
      |> Enum.join(" ")

    """
    <figure id="#{attrs["id"]}"#{class} style="#{styles}">
    #{retval}
    <figcaption>#{caption}</figcaption>
    </figure>
    """
  end

  defp parse_key_value(cap) do
    Regex.scan(~r/(\w+)="([^"]+)"/, cap, capture: :all_but_first)
    |> Enum.reduce(%{}, fn [key, val], acc ->
      Map.put(acc, key, val)
    end)
  end
end
