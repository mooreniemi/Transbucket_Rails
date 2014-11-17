#app/services/pin_creator_service.rb
class PinCreatorService
  attr_accessor :pin_params, :user, :pin_images

  def initialize(params, user)
    params = ActiveSupport::HashWithIndifferentAccess.new(params)
    @pin_images = params.delete("pin_images")
    @pin_params = ActiveSupport::HashWithIndifferentAccess.new(params["pin"])
    @user = user
  end

  def create
    pin = user.pins.new(pin_params.symbolize_keys)

    pin_images.each do |photo|
      pin.pin_images.build(photo: photo)
    end if pin_images

    return pin
  end
end
