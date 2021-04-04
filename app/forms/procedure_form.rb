require "reform/form/validation/unique_validator"

class ProcedureForm < Reform::Form
  property :name
  # NOTE: it shouldn't be required for usto repeat ourselves here but
  # I couldn't get the recommended ways of sharing between the model
  # and the form to work, documentation is from 2017 so...
  # https://trailblazer.to/2.0/gems/reform/validation.html#unique-validation
  validates :name, unique: { case_sensitive: false }

  property :gender
  property :body_type
  property :avg_sensation
  property :avg_satisfaction
  property :description
  property :slug, writable: false
end
