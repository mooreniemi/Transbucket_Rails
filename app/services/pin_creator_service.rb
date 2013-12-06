#app/services/pin_creator_service.rb
class PinCreatorService
  attr_accessor :params, :surgeon_attributes, :procedure_attributes, :user

  def initialize(pin_params, user)
    @params = ActiveSupport::HashWithIndifferentAccess.new(pin_params)
    @surgeon_attributes = ActiveSupport::HashWithIndifferentAccess.new(@params["surgeon_attributes"])
    @procedure_attributes = ActiveSupport::HashWithIndifferentAccess.new(@params["procedure_attributes"])
    @user = user
  end

  def create
    if @surgeon_attributes.present?
      @surgeon_attributes.delete('_destroy')
      @surgeon_attributes.delete('id')
      @surgeon_attributes['last_name'] = sanitize_name(@surgeon_attributes['last_name'])

      surgeon = Surgeon.new(@surgeon_attributes)
      @params["surgeon_id"] = surgeon.id if surgeon.save
    else
      @params["surgeon_id"] = @params["surgeon_id"].to_i == 0 ? Surgeon.find_by_last_name(@params["surgeon_id"].split(',').first).id.to_s : @params["surgeon_id"]
    end

    if @procedure_attributes.present?
      @procedure_attributes.delete('_destroy')
      procedure = Procedure.new(@procedure_attributes)
      @params["procedure_id"] = procedure.id if procedure.save
    else
      @params["procedure_id"] = @params["procedure_id"].to_i == 0 ? Procedure.find_by_name(@params["procedure_id"]).id.to_s : @params["procedure_id"]
    end

    @params.delete("surgeon_attributes")
    @params.delete("procedure_attributes")

    @user.pins.new(@params.symbolize_keys)
  end

  private

  def sanitize_name(name)
    name.gsub!(/(dr.|Dr.|dr|Dr|DR)/, '')
    name = name.split(',').first
    name.gsub!(/(MD$|md$|m.d.$|M.D.$)/, '')
    name.gsub!(/^\s/, '')
    name.gsub!(/\s$/, '')
    name
  end

end