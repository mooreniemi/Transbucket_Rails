class ProcedureForm < Reform::Form
  property :name
  property :gender
  property :body_type
  property :avg_sensation
  property :avg_satisfaction
  property :description
  property :slug, writable: false
end
