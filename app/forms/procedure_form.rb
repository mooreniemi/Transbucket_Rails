class ProcedureForm < Reform::Form
  property :name, validates: { presence: true, validate_unique_name: true }
  property :gender
  property :body_type
  property :avg_sensation
  property :avg_satisfaction
  property :description
  property :slug, writable: false
end
