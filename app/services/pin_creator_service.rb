#app/services/pin_creator_service.rb
class PinCreatorService
  attr_accessor :params, :user, :pin_images

  def initialize(params, user)
    @params = params.symbolize_keys
    @pin_images = params.delete(:pin_image_ids).split(",").reject!(&:blank?)
    @user = user
  end

  def create
    pin = user.pins.new(params)

    pin_images.each do |id|
      pin.pin_images << PinImage.find(id)
    end if pin_images

    pin
  end
end
