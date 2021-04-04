require "reform/form/validation/unique_validator"
class SurgeonForm < Reform::Form
  property :first_name
  validates :first_name, presence: true

  property :last_name
  validates :last_name, presence: true

  validates :last_name, unique: { scope: [:first_name, :last_name] }

  property :address
  property :city
  property :state
  property :zip
  property :country
  property :phone
  property :email
  property :url
  property :procedure_list
  property :notes
  property :slug, writable: false
end
