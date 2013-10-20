class FlagsController < ApplicationController
before_filter :authenticate_user!

  def create
    if Pin.find(params[:id]).present?
      @content = Pin.find(params[:id])
    else
      @content = Comment.find(params[:id])
    end

    @flag = @content.flag_from(current_user) if current_user.present?

    redirect_to pins_path, status: 302, notice: @flag

  end

end
