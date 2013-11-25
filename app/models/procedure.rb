class Procedure < ActiveRecord::Base
  attr_accessible :name, :type, :gender, :avg_sensation, :avg_satisfaction

  has_many :pins
  has_many :surgeons, through: :pins
end
