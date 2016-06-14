require 'reform'

class PinForm < Reform::Form
  feature Sync::SkipUnchanged

  property :user_id
  validates :user_id, presence: true

  property :surgeon, form: SurgeonForm,
           populator: :populate_surgeon!,
           prepopulator: ->(options) { self.surgeon = Surgeon.new }
  validates :surgeon, presence: true

  property :procedure, form: ProcedureForm,
           populator: :populate_procedure!,
           prepopulator: ->(options) { self.procedure = Procedure.new }
  validates :procedure, presence: true

  property :cost
  property :sensation
  property :satisfaction
  property :description
  property :revision
  property :details

  property :state

  collection :pin_images,
             populator: :populate_pin_images!,
             prepopulator: :prepopulate_pin_images! do
    property :pin_id
    property :photo
    property :caption
    property :_destroy, virtual: true, writeable: false
  end

  def prepopulate_pin_images!(options)
    3.times { self.pin_images << PinImage.new }
  end

  def populate_procedure!(fragment:, **)
    id = fragment["id"]
    if id.nil?
      self.procedure = Procedure.new
    else
      self.procedure = Procedure.find(id.to_i)
    end
  end

  def populate_surgeon!(fragment:, **)
    id = fragment["id"]
    if id.nil?
      self.surgeon = Surgeon.new
    else
      self.surgeon = Surgeon.find(id.to_i)
    end
  end

  def populate_pin_images!(fragment:, **)
    item = pin_images.find { |image| image.id == fragment["id"].to_i }

    if fragment["_destroy"] == "1"
      pin_images.delete(item)
      # sync may ignore this if image is otherwise unchanged, so we delete it early
      PinImage.destroy(item.id)
      return skip!
    end

    item ? item : pin_images.append(PinImage.new)
  end

  def save
    super
    model.save!
  end
end
