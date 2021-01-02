defmodule Cforum.BlogImport do
  import SweetXml

  alias Cforum.Repo

  alias Cforum.Users
  alias Cforum.Forums
  alias Cforum.Threads
  alias Cforum.Threads.ThreadHelpers
  alias Cforum.Messages
  alias Cforum.Settings
  alias Cforum.Media

  alias Cforum.BlogImport.Snippets
  alias Cforum.BlogImport.Autop

  def import(file) do
    {:ok, forum} = maybe_create_blog_forum()

    file
    |> File.stream!()
    |> xmap(
      authors: [
        ~x"//wp:author"l,
        id: ~x"./wp:author_id/text()"i,
        login: ~x"./wp:author_login/text()"s,
        email: ~x"./wp:author_email/text()"s,
        name: ~x"./wp:author_display_name/text()"s
      ],
      # categories: [
      #   ~x"//wp:category"l,
      #   id: ~x"./wp:term_id/text()"i,
      #   name: ~x"./wp:category_nicename/text()"s,
      #   parent: ~x"./wp:category_parent/text()"s
      # ],
      # tags: [
      #   ~x"//wp:tag"l,
      #   id: ~x"./wp:term_id/text()"i,
      #   name: ~x"./wp:tag_slug/text()"s
      # ],
      # terms: [
      #   ~x"//wp:term"l,
      #   type: ~x"./wp:term_taxonomy/text()"s,
      #   name: ~x"./wp:term_slug/text()"s,
      #   parent: ~x"./wp:term_parent/text()"s
      # ],
      posts: [
        ~x"//item"l,
        id: ~x"./wp:post_id/text()"i,
        title: ~x"./title/text()"s,
        link: ~x"./link/text()"s,
        title: ~x"./title/text()"s,
        pub_date: ~x"./pubDate/text()"s |> transform_by(&parse_date/1),
        creator: ~x"./dc:creator/text()"s,
        guid: [
          ~x"./guid",
          id: ~x"./text()"s,
          perma: ~x"./@isPermaLink"s
        ],
        description: ~x"./description/text()"s,
        encoded_content: ~x"./content:encoded/text()"s,
        encoded_excerpt: ~x"./excerpt:encoded/text()"s,
        post_date: ~x"./wp:post_date/text()"s |> transform_by(&parse_date/1),
        post_date_gmt: ~x"./wp:post_date_gmt/text()"s |> transform_by(&parse_date/1),
        comment_status: ~x"./wp:comment_status/text()"s,
        ping_status: ~x"./wp:ping_status/text()"s,
        post_name: ~x"./wp:post_name/text()"s,
        status: ~x"./wp:status/text()"s,
        post_parent: ~x"./wp:post_parent/text()"i,
        menu_order: ~x"./wp:menu_order/text()"i,
        post_type: ~x"./wp:post_type/text()"s,
        is_sticky: ~x"./wp:is_sticky/text()"i |> transform_by(&bool/1),
        categories: ~x"./category/text()"ls,
        attachment_url: ~x"./wp:attachment_url/text()"s,
        meta: [
          ~x"./wp:postmeta"l,
          key: ~x"./wp:meta_key/text()"s,
          value: ~x"./wp:meta_value/text()"s
        ],
        comments: [
          ~x"./wp:comment"l,
          id: ~x"./wp:comment_id/text()"i,
          author: ~x"./wp:comment_author/text()"s,
          email: ~x"./wp:comment_author_email/text()"s,
          url: ~x"./wp:comment_author_url/text()"s,
          date: ~x"./wp:comment_date/text()"s |> transform_by(&parse_date/1),
          date_gmt: ~x"./wp:comment_date_gmt/text()"s |> transform_by(&parse_date/1),
          content: ~x"./wp:comment_content/text()"s,
          approved: ~x"./wp:comment_approved/text()"s,
          type: ~x"./wp:comment_type/text()"s,
          author: ~x"./wp:comment_author/text()"s,
          parent: ~x"./wp:comment_parent/text()"s,
          user_id: ~x"./wp:comment_user_id/text()"i
        ]
      ]
    )
    |> transform_meta()
    |> transform_content()
    |> categorize_posts()
    |> map_authors()
    |> import_posts(forum)

    nil
  end

  defp transform_meta(data) do
    posts =
      data
      |> Map.get(:posts)
      |> Enum.map(fn %{meta: meta} = post ->
        Map.put(post, :meta, Enum.reduce(meta, %{}, fn %{key: key, value: value}, acc -> Map.put(acc, key, value) end))
      end)

    Map.put(data, :posts, posts)
  end

  defp transform_content(data) do
    posts =
      data
      |> Map.get(:posts)
      |> Enum.map(fn post ->
        post
        |> Map.put(:encoded_content, Autop.parse(post.encoded_content))
        |> Map.put(:encoded_excerpt, Autop.parse(post.encoded_excerpt))
      end)
      |> Enum.map(fn p ->
        p
        |> Map.put(:encoded_content, fix_markup(p.encoded_content))
        |> Map.put(:encoded_excerpt, fix_markup(p.encoded_excerpt))
      end)

    Map.put(data, :posts, posts)
  end

  defp fix_markup(str) do
    urls = Regex.scan(~r{src="(?:https?:)?//blog.selfhtml.org/[^"]+}, str) |> List.flatten()

    fixed_str =
      str
      |> String.replace(~r/<pre>\s*<code>/, "<pre><code class=\"block\">")
      |> String.replace(~r/\[gallery[^\]]+\]/, &Snippets.gallery/1)
      |> String.replace(~r/\[caption[^\]]+\].*?\[\/caption\]/, &Snippets.caption/1)

    Enum.reduce(urls, fixed_str, fn url, str ->
      orig_uri = String.replace_leading(url, "src=\"", "") |> maybe_add_protocol()
      {:ok, img_url} = create_image(orig_uri)

      str
      |> String.replace(url, "src=\"#{img_url}?size=medium")
      |> String.replace(orig_uri, img_url)
    end)
  end

  defp maybe_add_protocol("//blog" <> _ = s), do: "https:#{s}"
  defp maybe_add_protocol(s), do: s

  defp create_image(raw_url) do
    url =
      raw_url
      |> String.replace("ö", "%C3%B6")
      |> String.replace("ü", "%C3%BC")
      |> String.replace("ß", "%C3%9F")

    response = Tesla.get!(url)
    tmpfile = Briefly.create!()
    File.write!(tmpfile, response.body)

    {:ok, img} =
      Media.create_image(nil, %Plug.Upload{
        path: tmpfile,
        content_type: MIME.from_path(url),
        filename: Regex.replace(~r(.*/), url, "")
      })

    File.rm!(tmpfile)

    {:ok, CforumWeb.Views.ViewHelpers.Path.blog_image_url(CforumWeb.Endpoint, :show, img)}
  end

  defp categorize_posts(data) do
    posts = Enum.filter(data.posts, &(&1[:post_type] == "post" && &1[:status] == "publish"))
    attachments = Enum.filter(data.posts, &(&1[:post_type] == "attachment"))
    # rest = Enum.reject(data.posts, &(&1[:post_type] == "post"))

    data
    |> Map.put(:posts, posts)
    |> Map.put(:attachments, attachments)

    # |> Map.put(:post_alikes, rest)
  end

  defp import_posts(data, forum) do
    Repo.transaction(
      fn ->
        Enum.each(data[:posts], fn post ->
          img = create_thumbnail_image(post.meta["_thumbnail_id"], data.attachments)

          {:ok, thread, message} =
            Threads.create_thread(
              %{
                "forum_id" => forum.forum_id,
                "subject" => post.title,
                "author" => post.creator[:author],
                "content" => post.encoded_content,
                "excerpt" => post.encoded_excerpt,
                "tags" => post.categories
              },
              post.creator[:user],
              forum,
              [forum],
              create_tags: true,
              format: "html",
              created_at: post.post_date |> Timex.to_datetime(),
              updated_at: post.post_date |> Timex.to_datetime(),
              slug: gen_slug(post),
              latest_message: post.post_date |> Timex.to_datetime(),
              notify: false
            )

          if img do
            {:ok, _m} =
              Messages.update_message(message, %{"thumbnail" => img}, nil, [forum], updated_at: message.updated_at)

            File.rm!(img.path)
          end

          import_comments(thread, message, forum, post)
        end)
      end,
      timeout: :infinity
    )

    data
  end

  defp create_thumbnail_image(id, _) when is_nil(id) or id == "", do: nil

  defp create_thumbnail_image(id, attachments) do
    entry = Enum.find(attachments, &(&1.id == String.to_integer(id)))
    if is_nil(entry), do: raise("attachment #{id} not found!")

    response = Tesla.get!(entry.attachment_url)
    tmpfile = Briefly.create!()
    File.write!(tmpfile, response.body)

    %Plug.Upload{
      path: tmpfile,
      content_type: MIME.from_path(entry.attachment_url),
      filename: Regex.replace(~r(.*/), entry.attachment_url, "")
    }
  end

  defp gen_slug(post, num \\ 0) do
    s =
      ((post.post_date
        |> Timex.lformat!("/%Y/%b/%d/", "en", :strftime)
        |> String.downcase()) <> maybe_add_num(num) <> post.post_name)
      |> String.slice(0, 255)

    if ThreadHelpers.slug_taken?(s),
      do: gen_slug(post, num + 1),
      else: s
  end

  defp maybe_add_num(num) when is_nil(num) or num == 0, do: ""
  defp maybe_add_num(num), do: "#{num}-"

  defp import_comments(_, _, _, %{comments: []}), do: nil

  defp import_comments(thread, message, forum, %{comments: comments}) do
    comments
    |> Enum.filter(&(&1.approved == "1" && &1.type == "comment"))
    |> Enum.map(fn
      %{author: %{author: ""}} = comment -> put_in(comment.author.author, "Anonymous")
      p -> p
    end)
    |> Enum.each(fn comment ->
      {:ok, _msg} =
        Messages.create_message(
          %{
            "forum_id" => message.forum_id,
            "subject" => message.subject,
            "author" => comment.author.author,
            "content" => comment.content,
            "tags" => Enum.map(message.tags, & &1.tag_name)
          },
          comment.author.user,
          [forum],
          thread,
          message,
          format: "html",
          created_at: comment.date |> Timex.to_datetime(),
          updated_at: comment.date |> Timex.to_datetime()
        )
    end)
  end

  @author_mappings %{
    "juergen" => "JürgenB",
    "mscharwies" => "Matthias Scharwies",
    "mapsel" => "Matthias Apsel",
    "felixriesterer" => "Felix Riesterer",
    "marchaunschild" => "Marc",
    "goetzbuerkle" => "goetz",
    "stefanmuenz" => "stefanm",
    "timtepasse" => "Tim T—",
    "Robert Bienert" => "Robert B.",
    "redaktion" => "selfhtml",
    "christiankruse" => "Christian Kruse",
    "m" => "m."
  }

  defp map_authors(data) do
    posts =
      data
      |> Map.get(:posts)
      |> Enum.map(&author_mapping(data[:authors], &1))

    Map.put(data, :posts, posts)
  end

  defp author_mapping(authors, %{creator: creator} = post) do
    comments =
      Enum.map(post.comments, fn comment ->
        name = comment.author |> String.trim()
        user = Users.get_user_by_username(@author_mappings[name] || name)
        author = Enum.find(authors, &(&1[:login] == name)) || %{name: @author_mappings[name] || name}

        Map.put(comment, :author, %{user: user, username: name, author: author[:name]})
      end)

    user = Users.get_user_by_username(@author_mappings[creator] || creator)
    author = Enum.find(authors, &(&1[:login] == creator)) || %{name: @author_mappings[creator] || creator}

    post
    |> Map.put(:creator, %{user: user, username: creator, author: author[:name]})
    |> Map.put(:comments, comments)
  end

  defp parse_date(value) do
    cond do
      value in ["", "0000-00-00 00:00:00"] -> nil
      Regex.match?(~r/^\d{4}/, value) -> Timex.parse!(value, "%Y-%m-%d %H:%M:%S", :strftime)
      true -> Timex.parse!(value, "%a, %d %b %Y %H:%M:%S %z", :strftime)
    end
  end

  defp bool(v) when v == "" or v == 0 or is_nil(v) or v == "0", do: false
  defp bool(_), do: true

  defp maybe_create_blog_forum() do
    case Forums.get_forum_by_type("blog") do
      nil ->
        {:ok, forum} =
          Forums.create_forum(nil, %{
            slug: "weblog",
            short_name: "Weblog",
            name: "SELFHTML Weblog",
            type: "blog",
            description: "Das Weblog als Ergänzung zu SELFHTML",
            standard_permission: "read",
            keywords: "SELFHTML, Weblog",
            position: 5,
            active: true,
            visible: true
          })

        Settings.create_setting(nil, %{
          forum_id: forum.forum_id,
          options: %{"max_message_length" => 122_880, "max_tags_per_message" => 10, "archiver_active" => "no"}
        })

        {:ok, forum}

      forum ->
        {:ok, forum}
    end
  end
end
