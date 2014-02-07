class Surgeon < ActiveRecord::Base
  include SanitizeNames
  has_many :pins
  has_many :skills
  has_many :procedures, through: :skills

  attr_accessible :address, :city, :country, :email, :id, :first_name, :last_name, :phone, :procedure_list, :state, :url, :zip, :notes

  scope :has_procedures, joins(:procedures).
     group('surgeons.id').
     having('count(procedures.id) > 0')

  def to_s
    first_name.nil? ? last_name : last_name + ', ' + first_name
  end

  def self.names
   self.where("surgeons.last_name IS NOT NULL")
   .pluck_all(:first_name, :last_name)
   .collect! {|e| e["first_name"].nil? ? e["last_name"] : e["last_name"] + ', ' + e["first_name"] }
   .sort
  end
end
