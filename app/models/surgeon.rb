class Surgeon < ActiveRecord::Base
  has_many :pins
  has_many :skills
  has_many :procedures, through: :skills

  attr_accessible :address, :city, :country, :email, :id, :first_name, :last_name, :phone, :procedures, :state, :url, :zip, :notes

  def sanitize_name
    query.gsub!(/(dr.|Dr.|dr|Dr|MD|md|M.D.)/, '')
  end
end
