class FlagsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_moderator!, only: :destroy
  after_action :flash_to_headers

  def create
    type, id = content_reference
    @flag = Flag.new(current_user, find_content(type, id)).flag_on

    respond_to do |format|
      if @flag[:status].present?
        flash[:notice] = t('flash.content_flagged')
        format.json { render json: @flag, status: :created }
      else
        format.json { render json: @flag.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    type, id = content_reference

    @content = find_content(type, id)
    ModerationEventRecorder.record(action: :unflag, user: current_user, content: @content)
    @content.votes.down.destroy_all
    publish_status = @content.publish!

    respond_to do |format|
      if publish_status
        flash[:notice] = t('flash.removed_flags')
        format.json { render json: { status: 'unflagged'}, status: :ok }
      else
        format.json { render json: @content, status: :unprocessable_entity }
      end
    end
  end

  private

  def content_reference
    return ['pin', params[:pin_id]] if params[:pin_id].present?
    return ['comment', params[:comment_id]] if params[:comment_id].present?

    key = params.keys.last.to_s
    [key.split('_').first, params[key]]
  end

  def find_content(type, id)
    if type == "pin"
      content = Pin.find(id)
    else
      content = Comment.find(id)
    end
  end

  def flash_to_headers
    return unless request.xhr?
    response.headers['X-Message'] = flash_message
    response.headers["X-Message-Type"] = flash_type.to_s

    # Prevents flash from appearing after page reload.
    # Side-effect: flash won't appear after a redirect.
    # Comment-out if you use redirects.
    flash.discard
  end

  def flash_message
    [:error, :warning, :notice].each do |type|
      return flash[type] unless flash[type].blank?
    end
    return ''
  end

  def flash_type
    [:error, :warning, :notice].each do |type|
      return type unless flash[type].blank?
    end
  end

  def require_moderator!
    head :forbidden unless current_user.moderator?
  end

end
