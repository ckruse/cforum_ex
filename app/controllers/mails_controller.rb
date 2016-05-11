# -*- encoding: utf-8 -*-

class MailsController < ApplicationController
  include UserDataHelper

  before_filter :index_users

  authorize_controller { authorize_user }

  def index_users
    cu    = current_user
    mails = PrivMessage.
            select("(CASE recipient_id WHEN #{cu.user_id} THEN sender_name ELSE recipient_name END) AS username, is_read, COUNT(*) AS cnt").
            where('owner_id = ?', current_user.user_id).
            group("username, case recipient_id when #{cu.user_id} then sender_id else recipient_id end, is_read")

    @mail_users = {}
    mails.each do |mu|
      @mail_users[mu.username] ||= {read: 0, unread: 0}
      @mail_users[mu.username][mu.is_read? ? :read : :unread] += mu.cnt
    end
  end

  def index
    if params[:user]
      @user  = params[:user]
      @user_object = User.where(username: params[:user]).first
      @mails = PrivMessage.
               preload(:sender, :recipient).
               where("owner_id = ? AND (sender_name = ? OR recipient_name = ?)",
                     current_user.user_id, @user, @user)

    else
      @mails = PrivMessage.
               preload(:sender, :recipient).
               where(owner_id: current_user.user_id)
    end

    @mails = sort_query(%w(created_at sender recipient subject),
                        @mails, {sender: "sender_name",
                                 recipient: "recipient_name"},
                        {dir: :desc})#.
             #page(params[:page]).per(conf('pagination').to_i)

    @mail_groups = {}
    @mail_groups_keys = []
    @mails.each do |mail|
      key = mail.subject.gsub(/^Re: /, '') + '-' + mail.partner(current_user)
      @mail_groups_keys << key if @mail_groups[key].blank?

      @mail_groups[key] ||= []
      @mail_groups[key] << mail
    end

    @mail_groups_keys.each do |k|
      @mail_groups[k] = @mail_groups[k].sort { |a,b| a.created_at <=> b.created_at }
    end
  end

  def show
    @mail = PrivMessage.includes(:sender, :recipient).
      where(owner_id: current_user.user_id, priv_message_id: params[:id]).first!

    unless @mail.is_read
      PrivMessage.transaction do
        @mail.update(is_read: true)

        if n = Notification.where(recipient_id: current_user.user_id,
                                    oid: @mail.priv_message_id,
                                    otype: 'mails:create', is_read: false).first
          @new_notifications -= [n]

          if uconf('delete_read_notifications_on_new_mail') == 'yes'
            n.destroy
          else
            n.is_read = true
            n.save!
          end
        end
      end
    end
  end

  def priv_message_params
    params.require(:priv_message).permit(:recipient_id, :subject, :body)
  end

  def new
    @mail = PrivMessage.new(params[:priv_message].blank? ? {} :
                              priv_message_params)

    if not params[:priv_message_id].blank? and
        @parent = PrivMessage.where(owner_id: current_user.user_id,
                                      priv_message_id: params[:priv_message_id]).first!
      @mail.recipient_id = @parent.recipient_id == current_user.user_id ? @parent.sender_id : @parent.recipient_id
      @mail.subject      = @parent.subject =~ /^Re:/i ? @parent.subject : 'Re: ' + @parent.subject
      @mail.body         = @parent.to_quote(self) if params.has_key?(:quote_old_message)
    end

    @mail.body = gen_content(@mail.body, @mail.recipient.try(:username))
  end

  def create
    @mail           = PrivMessage.new(priv_message_params)
    @mail.sender_id = current_user.user_id
    @mail.sender_name = current_user.username
    @mail.owner_id  = current_user.user_id
    @mail.is_read   = true

    @mail.body      = PrivMessage.to_internal(@mail.body)

    @preview = !params[:preview].blank?

    saved = false
    if not @mail.recipient_id.blank?
      recipient = User.find(@mail.recipient_id)

      @mail.recipient_name = recipient.username

      @mail_recipient           = PrivMessage.new(priv_message_params)
      @mail_recipient.sender_id = current_user.user_id
      @mail_recipient.sender_name = current_user.username
      @mail_recipient.recipient_name = recipient.username
      @mail_recipient.owner_id  = recipient.user_id
      @mail_recipient.body      = PrivMessage.to_internal(@mail_recipient.body)

      if not @preview
        PrivMessage.transaction do
          if @mail.save
            saved = @mail_recipient.save
          end

          if saved
            notify_user(
              user: recipient,
              hook: 'notify_on_new_mail',
              subject: t('notifications.new_mail',
                         user: current_user.username,
                         subject: @mail.subject),
              path: mail_path(current_user.username, @mail_recipient),
              oid: @mail_recipient.priv_message_id,
              otype: 'mails:create',
              icon: 'icon-new-mail',
              body: @mail.to_txt
            )
          end

          raise ActiveRecord::Rollback.new unless saved
        end
      end

    else
      flash[:error] = t('mails.define_recipient_please')
    end

    respond_to do |format|
      if saved
        format.html { redirect_to mail_url(recipient.username, @mail),
          notice: t('mails.sent') }
        format.json { render json: @mail, status: :created }

        publish('mail:create', {type: 'mail', mail: @mail}, '/users/' + @mail.recipient_id.to_s)
      else
        format.html { render :new }
        format.json { render json: @mail.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @mail = PrivMessage.where(owner_id: current_user.user_id,
                                priv_message_id: params[:id]).first!
    @mail.destroy

    respond_to do |format|
      format.html { redirect_to mails_url, notice: t('mails.destroyed') }
      format.json { head :no_content }
    end
  end

  def batch_destroy
    unless params[:ids].blank?
      PrivMessage.transaction do
        @mails = PrivMessage.where(owner_id: current_user.user_id,
                                     priv_message_id: params[:ids])
        @mails.each do |m|
          m.destroy
        end
      end
    end

    redirect_to mails_url, notice: t('mails.destroyed')
  end

  def mark_read_unread
    @mail = PrivMessage.where(owner_id: current_user.user_id,
                                priv_message_id: params[:id]).first!

    @mail.is_read = !@mail.is_read

    respond_to do |format|
      if @mail.save
        format.html { redirect_to mails_url, notice: t('mails.marked_' + (@mail.is_read? ? 'read' : 'unread')) }
        format.json { render json: @mail }
      else
        format.html { redirect_to mails_url, notice: t('global.something_went_wrong') }
        format.json { render json: @mail.errors, status: :unprocessable_entity }
      end
    end

  end

end

# eof
