require 'reform'

class PinForm < Reform::Form
  feature Sync::SkipUnchanged

  property :user_id
  validates :user_id, presence: true

  property :surgeon, form: SurgeonForm, populator: :populate_surgeon!
  validates :surgeon, presence: true

  property :procedure, form: ProcedureForm, populator: :populate_procedure!
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
    self.procedure = (fragment["id"].nil? ? Procedure.new : Procedure.find(fragment["id"].to_i))
  end

  def populate_surgeon!(fragment:, **)
    self.surgeon = (fragment["id"].nil? ? Surgeon.new : Surgeon.find(fragment["id"].to_i))
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
