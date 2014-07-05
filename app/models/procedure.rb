class Procedure < ActiveRecord::Base
  has_many :pins
  has_many :skills
  has_many :surgeons, through: :skills

  # attr_accessible :name, :body_type, :gender, :avg_sensation, :avg_satisfaction

  validates :name, uniqueness: true

  def to_s
    name
  end
end
