class Procedure < ActiveRecord::Base
  include Searchable
  include Stats
  include CommentsHelper
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :pins
  has_many :skills
  has_many :surgeons, through: :skills

  acts_as_commentable

  # attr_accessible :name, :body_type, :gender, :avg_sensation, :avg_satisfaction

  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
  end

  validates :name, uniqueness: true
  validates :name, presence: true

  def to_s
    name
  end

  def self.names
    self.pluck(:name).sort
  end
end
