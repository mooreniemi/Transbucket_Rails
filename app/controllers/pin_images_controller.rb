class PinImagesController < ApplicationController
  def destroy
    @pin = Pin.find(params[:pin_id])
    @pin_image = PinImage.find(params[:id])

    respond_to do |format|
      if  @pin_image.destroy
        format.html { redirect_to :back, notice: 'Pin was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back }
        format.json { render json: @pin.errors, status: :unprocessable_entity }
      end
    end
  end
end
