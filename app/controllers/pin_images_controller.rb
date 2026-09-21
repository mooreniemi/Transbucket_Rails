class PinImagesController < ApplicationController
  # Every action changes or reveals photo records, so all of them need an account.
  # (These endpoints used to be open to anyone: an anonymous request could upload
  # images and delete any post's photos by id.)
  before_filter :authenticate_user!
  before_filter :find_image_and_pin, only: [:update, :destroy]
  before_filter :authorize_change, only: [:update, :destroy]
  respond_to :json

  def index
    @pin_images = Pin.find(params[:pin_id]).pin_images
    respond_with(@pin_images)
  end

  def update
    @pin_image.update_attributes(caption: params[:caption])
    render json: { id: @pin_image.id, caption: @pin_image.caption }
  end

  def create
    @pin_images = upload_params.collect do |file|
      PinImage.create!(
        # pin: Pin.find(params[:pin_id]),
        photo: file[:photo],
        caption: file[:caption]
      )
    end
    if @pin_images.present?
      render json: { id: @pin_images.map(&:id) }, :status => 200
    else
      #  you need to send an error header, otherwise Dropzone
      #  will not interpret the response as an error:
      render json: { error: @pin_images.errors.full_messages.join(',') }, :status => 400
    end
  end

  def destroy
    respond_to do |format|
      if @pin_image.destroy
        format.js
      else
        format.json { render json: @pin.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # A photo belongs to a post through its pin. A photo that has just been uploaded
  # and not yet attached to a post has no pin, so there is nobody to check against;
  # it is not shown anywhere until a post claims it.
  def find_image_and_pin
    if params[:pin_id]
      @pin = Pin.find(params[:pin_id])
      @pin_image = @pin.pin_images.find(params[:id])
    else
      @pin_image = PinImage.find(params[:id])
      @pin = @pin_image.pin
    end
  end

  # Owner or admin may change a post's photos; moderators may also remove them,
  # as they may remove whole posts (see PinsController#validate_user).
  def authorize_change
    return if @pin.nil? && action_name == 'update'
    return head(:forbidden) if @pin.nil?

    allowed = current_user == @pin.user || current_user.admin? || (action_name == 'destroy' && current_user.moderator?)
    head :forbidden unless allowed
  end

  def upload_params
    pin_image_params.map(&:last)
  end

  def pin_image_params
    params.require(:pin_images)
  end
end
