defmodule CforumWeb.Views.Helpers.Button do
  @moduledoc """
  This module defines button helpers to avoid boiler plate
  """

  use Phoenix.HTML

  import CforumWeb.Gettext

  @doc """
  Generates a button with a &lt;form&gt; for not very specific actions

  `opts` is a keyword list, special values are `:to` defining the
  target URL and `:method` defining the HTTP method. Every other
  attribute will be set as an attribute on the generated
  &lt;button&gt; tag.

  ### Examples

      default_button("foo", to: "bar")
      => <form action="bar" class="cf-inline-form" method="post">
           ...
           <button class="cf-btn" type="submit">foo</button>
         </form>

      default_button("foo", to: "bar", method: :delete)
      => <form action="bar" class="cf-inline-form" method="post">
           ...
           <input name="_method" type="hidden" value="delete">
           <button class="cf-btn" type="submit">foo</button>
         </form>

      default_button("foo", to: "bar", class: "lulu")
      => <form action="bar" class="cf-inline-form" method="post">
           ...
           <input name="_method" type="hidden" value="delete">
           <button class="cf-btn lulu" type="submit">foo</button>
         </form>

      default_button(to: "bar", method: :delete) do
        {:safe, "<b>foo</b>"}
      end
      => <form action="bar" class="cf-inline-form" method="post">
           ...
           <input name="_method" type="hidden" value="delete">
           <button class="cf-btn" type="submit"><b>foo</b></button>
         </form>
  """
  def default_button(opts, do: contents),
    do: cf_button(Keyword.update(opts, :class, "cf-btn", &(&1 <> " cf-btn")), do: contents)

  def default_button(text, opts), do: cf_button(text, Keyword.update(opts, :class, "cf-btn", &(&1 <> " cf-btn")))

  @doc """
  Generates a button with a &lt;form&gt; for not very specific actions
  for an index view, e.g. a table with a list of relations; see `default_button/2`.
  """
  def default_index_button(opts, do: contents),
    do: cf_button(Keyword.update(opts, :class, "cf-index-btn", &(&1 <> " cf-index-btn")), do: contents)

  def default_index_button(text, opts),
    do: cf_button(text, Keyword.update(opts, :class, "cf-index-btn", &(&1 <> " cf-index-btn")))

  @doc """
  Generates a button with a &lt;form&gt; for a primary action; see `default_button/2`.
  """
  def primary_button(opts, do: contents),
    do: cf_button(Keyword.update(opts, :class, "cf-primary-btn", &(&1 <> " cf-primary-btn")), do: contents)

  def primary_button(text, opts),
    do: cf_button(text, Keyword.update(opts, :class, "cf-primary-btn", &(&1 <> " cf-primary-btn")))

  @doc """
  Generates a button with a &lt;form&gt; for a primary action for an
  index view, e.g. a table with a list of relations; see
  `default_button/2`.
  """
  def primary_index_button(opts, do: contents),
    do: cf_button(Keyword.update(opts, :class, "cf-primary-index-btn", &(&1 <> " cf-primary-index-btn")), do: contents)

  def primary_index_button(text, opts),
    do: cf_button(text, Keyword.update(opts, :class, "cf-primary-index-btn", &(&1 <> " cf-primary-index-btn")))

  @doc """
  Generates a button with a &lt;form&gt; for a destructive action; see
  `default_button/2`. Additionally it sets a `data-confirm`
  attribute the UI can intervene on and make sure that the user will
  be asked for confirmation.
  """
  def destructive_button(opts, do: contents) do
    opts =
      opts
      |> Keyword.update(:class, "cf-destructive-btn", &(&1 <> " cf-destructive-btn"))
      |> Keyword.update(:"data-confirm", gettext("Are you sure?"), & &1)

    cf_button(opts, do: contents)
  end

  def destructive_button(text, opts) do
    opts =
      opts
      |> Keyword.update(:class, "cf-destructive-btn", &(&1 <> " cf-destructive-btn"))
      |> Keyword.update(:"data-confirm", gettext("Are you sure?"), & &1)

    cf_button(text, opts)
  end

  @doc """
  Generates a button with a &lt;form&gt; for a destructive action
  for an index view, e.g. a table with a list of relations; see `destructive_button/2`.
  """
  def destructive_index_button(opts, do: contents) do
    opts =
      opts
      |> Keyword.update(:class, "cf-destructive-index-btn", &(&1 <> " cf-destructive-index-btn"))
      |> Keyword.update(:"data-confirm", gettext("Are you sure?"), & &1)

    cf_button(opts, do: contents)
  end

  def destructive_index_button(text, opts) do
    opts =
      opts
      |> Keyword.update(:class, "cf-destructive-index-btn", &(&1 <> " cf-destructive-index-btn"))
      |> Keyword.update(:"data-confirm", gettext("Are you sure?"), & &1)

    cf_button(text, opts)
  end

  @doc """
  Generates a button that uses a regular HTML form to submit to the given URL.
  Useful to ensure that links that change data are not triggered by
  search engines and other spidering software.

  ## Examples
      button("hello", to: "/world")
      #=> <form action="/world" class="button" method="post">
        <input name="_csrf_token" value="">
        <button type="submit">hello</button>
      </form>
    
      button("hello", to: "/world", method: "get", class: "btn")
      #=> <form action="/world" class="btn" method="get">
        <button type="submit">hello</button>
      </form>

  ## Options

  * `:to` - the page to link to. This option is required
  * `:method` - the method to use with the button. Defaults to :post.
  * `:form` - the options for the form. Defaults to `[class: "button", enforce_utf8: false]`

  All other options are forwarded to the underlying button input.
  """
  def cf_button(opts, do: contents) do
    {to, form, opts} = extract_button_options(opts)

    form_tag to, form do
      Phoenix.HTML.Form.submit(opts, do: contents)
    end
  end

  def cf_button(text, opts) do
    {to, form, opts} = extract_button_options(opts)

    form_tag to, form do
      Phoenix.HTML.Form.submit(text, opts)
    end
  end

  defp extract_button_options(opts) do
    {to, opts} = pop_required_option!(opts, :to, "option :to is required in button/2")
    {method, opts} = Keyword.pop(opts, :method, :post)

    {form, opts} = form_options(opts, method, "cf-inline-form")

    {to, form, opts}
  end

  defp pop_required_option!(opts, key, error_message) do
    {value, opts} = Keyword.pop(opts, key)

    unless value do
      raise ArgumentError, error_message
    end

    {value, opts}
  end

  defp form_options(opts, method, class) do
    {form, opts} = Keyword.pop(opts, :form, [])

    form =
      form
      |> Keyword.put_new(:class, class)
      |> Keyword.put_new(:method, method)
      |> Keyword.put_new(:enforce_utf8, false)

    {form, opts}
  end

  @doc """
  Generates a button with a link for not very specific actions

  `opts` is a keyword list, the only special values is `:to` defining
  the target URL. Every other attribute will be set as an attribute on
  the generated &lt;a&gt; tag.

  ### Examples

      default_button_link("foo", to: "bar")
      => <a href="bar" class="cf-btn">foo</a>

      default_button_link("foo", to: "bar", class: "lulu")
      => <a href="bar" class="cf-btn lulu">foo</a>

      default_button_link(to: "bar") do
        {:safe, "<b>foo</b>"}
      end
      => <a href="bar" class="cf-btn"><b>foo</b></a>
  """
  def default_button_link(opts, do: contents),
    do: link(Keyword.update(opts, :class, "cf-btn", &(&1 <> " cf-btn")), do: contents)

  def default_button_link(text, opts), do: link(text, Keyword.update(opts, :class, "cf-btn", &(&1 <> " cf-btn")))

  @doc """
  Generates a button with a link for not very specific actions for an
  index view, e.g. a table with a list of relations; see
  `default_button_link/2`.
  """
  def default_index_button_link(opts, do: contents),
    do: link(Keyword.update(opts, :class, "cf-index-btn", &(&1 <> " cf-index-btn")), do: contents)

  def default_index_button_link(text, opts),
    do: link(text, Keyword.update(opts, :class, "cf-index-btn", &(&1 <> " cf-index-btn")))

  @doc """
  Generates a button with a link for a primary action; see
  `default_button_link/2`.
  """
  def primary_button_link(opts, do: contents),
    do: link(Keyword.update(opts, :class, "cf-primary-btn", &(&1 <> " cf-primary-btn")), do: contents)

  def primary_button_link(text, opts),
    do: link(text, Keyword.update(opts, :class, "cf-primary-btn", &(&1 <> " cf-primary-btn")))

  @doc """
  Generates a button with a link for a primary action for an index
  view, e.g. a table with a list of relations; see
  `default_button_link/2`.
  """
  def primary_index_button_link(opts, do: contents),
    do: link(Keyword.update(opts, :class, "cf-primary-index-btn", &(&1 <> " cf-primary-index-btn")), do: contents)

  def primary_index_button_link(text, opts),
    do: link(text, Keyword.update(opts, :class, "cf-primary-index-btn", &(&1 <> " cf-primary-index-btn")))

  @doc """
  Generates a button with a link for a destructive action; see
  `default_button_link/2`. Additionally it sets a `data-confirm`
  attribute the UI can intervene on and make sure that the user will
  be asked for confirmation.
  """
  def destructive_button_link(opts, do: contents) do
    opts =
      opts
      |> Keyword.update(:class, "cf-destructive-btn", &(&1 <> " cf-destructive-btn"))
      |> Keyword.update(:"data-confirm", gettext("Are you sure?"), & &1)

    link(opts, do: contents)
  end

  def destructive_button_link(text, opts) do
    opts =
      opts
      |> Keyword.update(:class, "cf-destructive-btn", &(&1 <> " cf-destructive-btn"))
      |> Keyword.update(:"data-confirm", gettext("Are you sure?"), & &1)

    link(text, opts)
  end

  @doc """
  Generates a button with a link for a destructive action for an index
  view, e.g. a table with a list of relations; see
  `destructive_button_link/2`.
  """
  def destructive_index_button_link(opts, do: contents) do
    opts =
      opts
      |> Keyword.update(:class, "cf-destructive-btn", &(&1 <> " cf-destructive-btn"))
      |> Keyword.update(:"data-confirm", gettext("Are you sure?"), & &1)

    link(opts, do: contents)
  end

  def destructive_index_button_link(text, opts) do
    opts =
      opts
      |> Keyword.update(:class, "cf-destructive-btn", &(&1 <> " cf-destructive-btn"))
      |> Keyword.update(:"data-confirm", gettext("Are you sure?"), & &1)

    link(text, opts)
  end

  @doc """
  Generates a submit button for not very specific actions

  `opts` is a keyword list, every attribute will be set as an
  attribute on the generated &lt;button&gt; tag.

  ### Examples

      default_submit("foo")
      => <button type="submit" class="cf-btn">foo</a>

      default_button_link("foo", foo: "bar")
      => <button type="submit" foo="bar" class="cf-btn">foo</a>

      default_button_link(foo: "bar") do
        {:safe, "<b>foo</b>"}
      end
      => <button type="submit" class="cf-btn" foo="bar"><b>foo</b></a>
  """
  def default_submit(_, opts \\ [])

  def default_submit(opts, do: contents),
    do: submit(Keyword.update(opts, :class, "cf-btn", &(&1 <> " cf-btn")), do: contents)

  def default_submit(text, opts), do: submit(text, Keyword.update(opts, :class, "cf-btn", &(&1 <> " cf-btn")))

  @doc """
  Generates a submit button for a primary action; see
  `default_submit/2`.
  """
  def primary_submit(_, opts \\ [])

  def primary_submit(opts, do: contents),
    do: submit(Keyword.update(opts, :class, "cf-primary-btn", &(&1 <> " cf-primary-btn")), do: contents)

  def primary_submit(text, opts),
    do: submit(text, Keyword.update(opts, :class, "cf-primary-btn", &(&1 <> " cf-primary-btn")))

  @doc """
  Generates a submit button for a destructive action; see
  `default_submit/2`. Additionally it sets a `data-confirm`
  attribute the UI can intervene on and make sure that the user will
  be asked for confirmation.
  """
  def destructive_submit(_, opts \\ [])

  def destructive_submit(opts, do: contents) do
    opts =
      opts
      |> Keyword.update(:class, "cf-destructive-btn", &(&1 <> " cf-destructive-btn"))
      |> Keyword.update(:"data-confirm", gettext("Are you sure?"), & &1)

    submit(opts, do: contents)
  end

  def destructive_submit(text, opts) do
    opts =
      opts
      |> Keyword.update(:class, "cf-destructive-btn", &(&1 <> " cf-destructive-btn"))
      |> Keyword.update(:"data-confirm", gettext("Are you sure?"), & &1)

    submit(text, opts)
  end
end

# eof
