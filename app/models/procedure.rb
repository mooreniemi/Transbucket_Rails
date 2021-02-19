class Procedure < ActiveRecord::Base
  include Stats
  include CommentsHelper
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :pins
  has_many :skills
  has_many :surgeons, through: :skills

  acts_as_commentable

  # attr_accessible :name, :body_type, :gender, :avg_sensation, :avg_satisfaction

  validates :name, uniqueness: true
  validates :name, presence: true

  # save downcase, display capitalized
  before_validation { self.name.downcase! }

  def to_s
    name.capitalize
  end

  def self.names
    self.pluck(:name).sort
  end
end
