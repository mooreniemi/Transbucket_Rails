class Skill < ActiveRecord::Base
  # surgeon has_many :procedures, through: :skills
  # attr_accessible :surgeon_id, :procedure_id
  belongs_to :surgeon
  belongs_to :procedure
end
