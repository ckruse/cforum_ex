# -*- encoding: utf-8 -*-

class CfThreadsController < ApplicationController
  before_filter :require_login, :only => [:edit, :destroy]

  SHOW_THREADLIST = "show_threadlist"
  SHOW_THREAD = "show_thread"
  SHOW_NEW_THREAD = "show_new_thread"

  def index
    if params[:t]
      thread = CfThread.find_by_tid("t" + params[:t])

      if thread
        if params[:m] && message = thread.find_message(params[:m])
          return redirect_to message_path(thread, message)
        else
          return redirect_to thread_path(thread)
        end
      end
    end

    if ConfigManager.setting('use_archive')
      @threads = CfThread.index.includes(:messages).order('messages.created_at DESC')
    else
      @threads = CfThread.preload(:messages).order('cforum.threads.created_at DESC').limit(ConfigManager.setting('pagination', 10))
    end

    @threads.each do |t|
      t.gen_tree
      t.sort_tree
    end

    notification_center.notify(SHOW_THREADLIST, @threads)
  end

  def show
    @id = CfThread.make_id(params)
    @thread = CfThread.find_by_slug(@id)

    @thread.gen_tree
    @thread.sort_tree

    notification_center.notify(SHOW_THREAD, @thread)
  end

  def edit
    @id = CfThread.make_id(params)
    @thread = CfThread.find_by_slug!(@id)

    @thread.gen_tree
    @thread.sort_tree
  end

  def new
    @thread = CfThread.new
    @thread.message = CfMessage.new

    notification_center.notify(SHOW_NEW_THREAD, @thread)
  end

  def create
    now = Time.now

    @forum = CfForum.find_by_slug('default-forum')

    @thread = CfThread.new()
    @message = CfMessage.new(params[:cf_thread][:message])
    @thread.messages << @message
    @thread.message = @message

    @thread.forum_id = @forum.forum_id
    @thread.slug = CfThread.gen_id(@thread)

    respond_to do |format|
      if @thread.save
        format.html { redirect_to cf_message_url(@thread, @message), notice: 'Thread was successfully created.' } # todo: redirect to new thread
        format.json { render json: @thread, status: :created, location: @thread }
      else
        format.html { render action: "new" }
        format.json { render json: @thread.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end
end

# eof
