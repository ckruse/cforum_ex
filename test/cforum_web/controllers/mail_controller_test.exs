defmodule CforumWeb.MailControllerTest do
  use CforumWeb.ConnCase

  alias Cforum.Accounts.PrivMessages

  setup [:setup_login]

  describe "index" do
    test "lists all entries on index", %{conn: conn, user: user} do
      priv_message = insert(:priv_message, owner: user, recipient: user)
      conn = get(conn, mail_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("mails")
      assert html_response(conn, 200) =~ priv_message.subject
    end
  end

  describe "new mail" do
    test "renders form", %{conn: conn} do
      conn = get(conn, mail_path(conn, :new))
      assert html_response(conn, 200) =~ gettext("new mail")
    end
  end

  describe "create mail" do
    test "redirects to show when data is valid", %{conn: conn} do
      user = insert(:user)
      attrs = params_for(:priv_message, recipient_name: nil, sender_name: nil, recipient_id: user.user_id)
      conn = post(conn, mail_path(conn, :create), priv_message: attrs)

      assert %{id: id} = cf_redirected_params(conn)
      assert redirected_to(conn) =~ mail_path(conn, :show, id)

      conn = get(conn, mail_path(conn, :show, id))
      assert html_response(conn, 200) =~ gettext("mail from %{partner}", partner: user.username)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, mail_path(conn, :create), priv_message: %{})
      assert html_response(conn, 200) =~ gettext("new mail")
    end

    test "shows a preview when preview is set", %{conn: conn} do
      user = insert(:user)
      attrs = params_for(:priv_message, recipient_name: nil, sender_name: nil, recipient_id: user.user_id)
      conn = post(conn, mail_path(conn, :create), priv_message: attrs, preview: "yes")

      assert html_response(conn, 200) =~ gettext("new mail")
      assert html_response(conn, 200) =~ gettext("preview")
    end
  end

  describe "mark unread" do
    setup [:create_mail]

    test "marks mail as unread", %{conn: conn, mail: mail, user: user} do
      PrivMessages.mark_priv_message(mail, :read)
      mail = PrivMessages.get_priv_message!(user, mail.priv_message_id)
      assert mail.is_read == true

      post(conn, mail_path(conn, :update_unread, mail))
      mail = PrivMessages.get_priv_message!(user, mail.priv_message_id)
      assert mail.is_read == false
    end

    test "redirects to index after marking unread", %{conn: conn, mail: mail} do
      conn = post(conn, mail_path(conn, :update_unread, mail))
      assert redirected_to(conn) == mail_path(conn, :index)
    end
  end

  describe "delete mail" do
    setup [:create_mail]

    test "deletes chosen mail", %{conn: conn, mail: mail} do
      conn = delete(conn, mail_path(conn, :delete, mail))
      assert redirected_to(conn) == mail_path(conn, :index)
      assert_error_sent(404, fn -> get(conn, mail_path(conn, :show, mail.thread_id)) end)
    end
  end

  defp create_mail(%{user: user}) do
    mail = insert(:priv_message, owner: user, thread_id: 1)
    {:ok, mail: mail}
  end

  defp setup_login(%{conn: conn}) do
    user = insert(:user)
    {:ok, user: user, conn: login(conn, user)}
  end
end
