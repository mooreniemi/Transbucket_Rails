class Surgeon < ActiveRecord::Base
  attr_accessible :address, :city, :country, :email, :id, :first_name, :last_name, :phone, :procedures, :state, :url, :zip, :notes

  def sanitize_name
    query.gsub!(/(dr.|Dr.|dr|Dr|MD|md|M.D.)/, '')
  end
end
