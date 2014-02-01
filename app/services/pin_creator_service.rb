#app/services/pin_creator_service.rb
class PinCreatorService
  attr_accessor :params, :surgeon_attributes, :procedure_attributes, :user, :pin_images_attributes, :pin_images

  def initialize(pin_params, user)
    @params = pin_params.stringify_keys!
    @surgeon_attributes = params["surgeon_attributes"]
    @procedure_attributes = params["procedure_attributes"]
    @pin_images_attributes = params["pin_images_attributes"]
    @pin_images = []
    @user = user

    @surgeon_attributes.extend(SanitizeNames)
    @procedure_attributes.extend(SanitizeNames)
  end

  def create
    if pin_images_attributes.present?
      params["pin_images_attributes"] = pin_images_attributes.reject {|k, v| !v.include?(:photo) }
      params["pin_images_attributes"].values.each {|p| p.delete("_destroy")}
      params["pin_images_attributes"].each {|p| pin_images << PinImage.new(p.last) }
    end

    if surgeon_attributes.present?
      check_surgeon_attrs
    else
      find_or_default_surgeon
    end

    if procedure_attributes.present?
      check_procedure_attrs
    else
      find_or_default_procedure
    end

    params.delete("surgeon_attributes")
    params.delete("procedure_attributes")
    params.delete("pin_images_attributes")

    pin = user.pins.new(params.symbolize_keys)

    pin.pin_images << pin_images

    return pin
  end

  def check_surgeon_attrs
    surgeon_attributes.delete('_destroy')
    surgeon_attributes.delete('id')
    surgeon_attributes['last_name'] = surgeon_attributes.sanitize_last_name

    surgeon = Surgeon.new(surgeon_attributes)
    params["surgeon_id"] = surgeon.id if surgeon.save
  end

  def find_or_default_surgeon
    params["surgeon_id"] = params["surgeon_id"].to_i == 0 ? Surgeon.find_by_last_name(params["surgeon_id"].split(',').first).id.to_s : params["surgeon_id"]
  end

  def check_procedure_attrs
    procedure_attributes.delete('_destroy')
    procedure = Procedure.new(procedure_attributes)
    params["procedure_id"] = procedure.id if procedure.save
  end

  def find_or_default_procedure
    params["procedure_id"] = params["procedure_id"].to_i == 0 ? Procedure.find_by_name(params["procedure_id"]).id.to_s : params["procedure_id"]
  end
end