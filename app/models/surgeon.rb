class Surgeon < ActiveRecord::Base
  attr_accessible :address, :city, :country, :email, :id, :name, :phone, :procedures, :state, :url, :zip
end
