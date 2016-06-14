class Surgeon < ActiveRecord::Base
  include SanitizeNames
  has_many :pins
  has_many :skills
  has_many :procedures, through: :skills

  scope :has_procedures, -> { joins(:procedures).
                              group('surgeons.id').
                              having('count(procedures.id) > 0') }

  phony_normalize :phone, default_country_code: 'US'

  validates :last_name, uniqueness: { scope: :first_name }
  validates :last_name, presence: true

  def to_s
    first_name.nil? ? last_name : last_name.capitalize + ', ' + first_name.capitalize
  end

  def self.names
    self.pluck(:first_name, :last_name).
      collect! {|e| e[0].nil? ? e[1] : e.reverse.join(',') }.
      sort
  end
end
