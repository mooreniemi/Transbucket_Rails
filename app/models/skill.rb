class Skill < ActiveRecord::Base
  attr_accessible :surgeon_id, :procedure_id
  belongs_to :surgeon
  belongs_to :procedure
end
