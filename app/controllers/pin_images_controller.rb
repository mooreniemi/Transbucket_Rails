class PinImagesController < ApplicationController
  respond_to :json

  def update
    @pin_image = PinImage.find(params[:id])
    @pin_image.update_attributes(caption: params[:caption])
    respond_with(@pin_image)
  end

  def new
    # unused currently due to pin association
    @pin_image = PinImage.new
  end

  def create
    @pin_image = PinImage.create(pin_image_params)
    if @pin_image.save
      render json: { id: @pin_image.id }, :status => 200
    else
      #  you need to send an error header, otherwise Dropzone
      #  will not interpret the response as an error:
      render json: { error: @pin_image.errors.full_messages.join(',')}, :status => 400
    end
  end

  def destroy
    @pin = Pin.find(params[:pin_id])
    @pin_image = PinImage.find(params[:id])

    respond_to do |format|
      if @pin_image.destroy
        format.js
      else
        format.json { render json: @pin.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def pin_image_params
    params.require(:pin_image).permit(:photo)
  end
end
