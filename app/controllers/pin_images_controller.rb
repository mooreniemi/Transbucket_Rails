class PinImagesController < ApplicationController
  respond_to :json

  def index
    @pin_images = Pin.find(params[:pin_id]).pin_images
    respond_with(@pin_images)
  end

  def update
    pin_image = PinImage.where(id: params[:id]).first.
      update_attributes(caption: params[:caption])
    respond_with(pin_image)
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
    @pin = Pin.find(params[:pin_id])
    @pin_image = @pin.pin_images.find(params[:id])

    respond_to do |format|
      if @pin_image.destroy
        format.js
      else
        format.json { render json: @pin.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def upload_params
    # ActionController::Parameters stopped being Hash-like in Rails 5, and
    # the nested keys here are dynamic numeric upload indices ("0", "1", ...)
    # rather than a fixed, permit-able attribute list, so this converts to a
    # plain Hash rather than permitting each key by name.
    pin_image_params.to_unsafe_h.map(&:last)
  end

  def pin_image_params
    params.require(:pin_images)
  end
end
