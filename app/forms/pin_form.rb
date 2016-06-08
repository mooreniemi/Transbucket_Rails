require 'reform'

class PinForm < Reform::Form
  property :user_id
  validates :user_id, presence: true

  property :surgeon_id
  validates :surgeon_id, presence: true

  property :procedure_id
  validates :procedure_id, presence: true

  property :cost
  property :sensation
  property :satisfaction
  property :description
  property :revision
  property :details

  property :state

  collection :pin_images,
             populate_if_empty: PinImage,
             prepopulator: :prepopulate_pin_images! do
    property :pin_id
    property :photo
    property :caption
  end

  def prepopulate_pin_images!(options)
    3.times { self.pin_images << PinImage.new }
  end

  def save
    super
    model.save!
  end
end
