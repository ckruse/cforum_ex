# -*- coding: utf-8 -*-

defmodule CforumWeb.Views.Helpers.Button do
  use Phoenix.HTML

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
  * `:form` - the options for the form. Defaults to
  `[class: "button", enforce_utf8: false]`
  All other options are forwarded to the underlying button input.
  """
  def cf_button(opts, [do: contents]) do
    {to, form, opts} = extract_button_options(opts)

    form_tag(to, form) do
      Phoenix.HTML.Form.submit(opts, [do: contents])
    end
  end

  def cf_button(text, opts) do
    {to, form, opts} = extract_button_options(opts)

    form_tag(to, form) do
      Phoenix.HTML.Form.submit(text, opts)
    end
  end

  defp extract_button_options(opts) do
    {to, opts} = pop_required_option!(opts, :to, "option :to is required in button/2")
    {method, opts} = Keyword.pop(opts, :method, :post)

    {form, opts} = form_options(opts, method, "button_to")

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
end

# eof
