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
  end

  # property :surgeon, form: SurgeonForm
  # validates :surgeon, presence: true

  # property :procedure, form: ProcedureForm
  # validates :procedure, presence: true
end
