#app/services/pin_creator_service.rb
class PinUpdaterService
  attr_accessor :params, :surgeon_attributes, :procedure_attributes,
    :pin_image_ids, :user, :pin_images, :pin

  def initialize(pin_params, user)
    @params = pin_params.stringify_keys!
    @surgeon_attributes = @params["surgeon_attributes"]
    @procedure_attributes = @params["procedure_attributes"]
    @pin_image_ids = @params["pin_image_ids"].present? ? @params["pin_image_ids"].split(',').reject(&:empty?).map(&:to_i) : []
    @pin = Pin.find(@params["pin_id"])
    @user = user

    @surgeon_attributes.extend(SanitizeNames)
    @procedure_attributes.extend(SanitizeNames)
  end

  def update
    if surgeon_attributes.present?
      check_surgeon_attrs
    end

    if procedure_attributes.present?
      check_procedure_attrs
    end

    clear_out_hash

    if pin_image_ids.empty?
      pin.update_attributes(params.symbolize_keys)
    else
      pin.pin_images << PinImage.find(pin_image_ids)
      pin.save && pin.update_attributes(params.symbolize_keys)
    end
  end

  def check_surgeon_attrs
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

  def clear_out_hash
    params.delete("surgeon_attributes")
    params.delete("procedure_attributes")
    params.delete("pin_id")
  end
end
