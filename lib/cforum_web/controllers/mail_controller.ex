defmodule CforumWeb.MailController do
  use CforumWeb, :controller

  alias Cforum.Accounts.PrivMessage
  alias Cforum.Accounts.PrivMessages

  def index(conn, params) do
    sort_dir = uconf(conn, "mail_thread_sort")
    {sort_params, conn} = sort_collection(conn, [:created_at, :subject, :is_read], dir: ordering(sort_dir))
    count = PrivMessages.count_newest_priv_messages_of_each_thread(conn.assigns[:current_user])
    paging = CforumWeb.Paginator.paginate(count, page: params["p"])

    mails =
      PrivMessages.list_newest_priv_messages_of_each_thread(
        conn.assigns[:current_user],
        limit: paging.params,
        order: sort_params,
        messages_order: ordering(sort_dir)
      )

    render(conn, "index.html", mails: mails, paging: paging)
  end

  def show(conn, %{"id" => id}) do
    thread = PrivMessages.get_priv_message_thread!(conn.assigns[:current_user], id)
    Enum.each(thread, &PrivMessages.mark_priv_message(&1, :read))
    render(conn, "show.html", pm_thread: thread)
  end

  def new(conn, %{"parent_id" => id} = params) do
    parent = PrivMessages.get_priv_message!(conn.assigns[:current_user], id)

    changeset =
      PrivMessages.answer_changeset(
        %PrivMessage{},
        parent,
        strip_signature: uconf(conn, "quote_signature") != "yes",
        greeting: uconf(conn, "greeting"),
        farewell: uconf(conn, "farewell"),
        signature: uconf(conn, "signature"),
        quote: quote?(conn, params),
        std_replacement: gettext("you")
      )

    render(conn, "new.html", changeset: changeset, parent: parent)
  end

  def new(conn, params) do
    changeset =
      PrivMessages.new_changeset(
        %PrivMessage{},
        params["priv_message"] || %{},
        greeting: uconf(conn, "greeting"),
        farewell: uconf(conn, "farewell"),
        signature: uconf(conn, "signature"),
        std_replacement: gettext("you")
      )

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"priv_message" => priv_message_params} = params) do
    if Map.has_key?(params, "preview"),
      do: show_preview(conn, priv_message_params),
      else: create_message(conn, priv_message_params)
  end

  defp show_preview(conn, params) do
    {priv_message, changeset} = PrivMessages.preview_priv_message(params)
    render(conn, "new.html", changeset: changeset, priv_message: priv_message, preview: true)
  end

  def create_message(conn, priv_message_params) do
    case PrivMessages.create_priv_message(conn.assigns[:current_user], priv_message_params) do
      {:ok, priv_message} ->
        conn
        |> put_flash(:info, gettext("Mail created successfully."))
        |> redirect(to: mail_thread_path(conn, :show, priv_message))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update_unread(conn, %{"id" => id}) do
    priv_message = PrivMessages.get_priv_message!(conn.assigns[:current_user], id)
    PrivMessages.mark_priv_message(priv_message, :unread)

    conn
    |> put_flash(:info, gettext("Mail successfully marked as unread."))
    |> redirect(to: mail_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    priv_message = PrivMessages.get_priv_message!(conn.assigns[:current_user], id)
    PrivMessages.delete_priv_message(priv_message)

    conn
    |> put_flash(:info, gettext("Mail deleted successfully."))
    |> redirect(to: mail_path(conn, :index))
  end

  defp ordering("ascending"), do: :asc
  defp ordering(_), do: :desc

  defp quote?(conn, params) do
    if blank?(params["quote"]) do
      uconf(conn, "quote_by_default") == "yes"
    else
      params["quote"] == "yes"
    end
  end
end
