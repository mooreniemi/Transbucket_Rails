class SurgeonForm < Reform::Form
  property :first_name
  validates :first_name, presence: true

  property :last_name
  validates :last_name, presence: true

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
end
