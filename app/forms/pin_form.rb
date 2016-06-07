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

  collection :pin_images do
    property :photo_file_name
    validates :photo_file_name, presence: true

    property :photo_file_size
    validates :photo_file_size, presence: true

    property :photo_content_type
    validates :photo_content_type, presence: true

    property :caption
  end

  # property :surgeon, form: SurgeonForm
  # validates :surgeon, presence: true

  # property :procedure, form: ProcedureForm
  # validates :procedure, presence: true
end
