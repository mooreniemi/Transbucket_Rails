#app/services/pin_creator_service.rb
class PinCreatorService
  attr_accessor :pin_params, :surgeon_attributes, :procedure_attributes, :user, :pin_images

  def initialize(params, user)
    @surgeon_attributes = params.delete("surgeon_attributes")
    @procedure_attributes = params.delete("procedure_attributes")
    @pin_images = params.delete("pin_images")
    @pin_params = params["pin"].stringify_keys!
    @user = user

    @surgeon_attributes.extend(SanitizeNames)
    @procedure_attributes.extend(SanitizeNames)
  end

  def create
    if surgeon_attributes.present?
      check_surgeon_attrs
    end

    if procedure_attributes.present?
      check_procedure_attrs
    end

    pin = user.pins.new(pin_params.symbolize_keys)

    if pin_images
      pin_images.each { |photo|
        pin.pin_images.build(photo: photo)
      }
    end

    return pin
  end

  def check_surgeon_attrs
    return if surgeon_attributes.stringify_keys!['last_name'].nil?

    surgeon_attributes.delete('_destroy')
    surgeon_attributes.delete('id')
    surgeon_attributes['last_name'] = surgeon_attributes.sanitize_last_name

    surgeon = Surgeon.new(surgeon_attributes)
    params["surgeon_id"] = surgeon.id if surgeon.save
  end

  def check_procedure_attrs
    procedure_attributes.delete('_destroy')
    procedure = Procedure.new(procedure_attributes)
    params["procedure_id"] = procedure.id if procedure.save
  end
end
