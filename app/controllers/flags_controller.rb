class FlagsController < ApplicationController
  before_filter :authenticate_user!
  after_filter :flash_to_headers
  respond_to :js

  def create
    type = params.keys.last.split('_').first
    id = params.values.last
    @flag = Flag.new(current_user, find_content(type, id)).flag_on

    respond_to do |format|
      if @flag[:status].present?
        flash[:notice] = "Content flagged."
        format.js { render json: @flag, status: :created }
      else
        format.js { render json: @flag.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    type = params.keys.last.split('_').first
    id = params.values.last

    @content = find_content(type, id)
    @content.votes.down.destroy_all
    @content.publish!

    respond_to do |format|
      if @content.published?
        redirect_to pins_path
      else
        format.js {render json: @content, status: :unprocessable_entity }
      end
    end

  end

  private

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

end
