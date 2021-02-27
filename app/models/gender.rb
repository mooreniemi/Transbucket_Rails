class Gender < ActiveRecord::Base
  attr_accessible :name
  has_many :users

  def cis?
    name.downcase == "cisgender"
  end

  def afab?
    name.downcase == "FTM"
  end

  def amab?
    name.downcase == "MTF"
  end
end
