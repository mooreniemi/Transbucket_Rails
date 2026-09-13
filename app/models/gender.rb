class Gender < ActiveRecord::Base
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
