class Procedure < ActiveRecord::Base
  include Stats
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :pins
  has_many :skills
  has_many :surgeons, through: :skills

  acts_as_commentable

  # attr_accessible :name, :body_type, :gender, :avg_sensation, :avg_satisfaction

  validates :name, uniqueness: true
  validates :name, presence: true

  def to_s
    name
  end

  def self.names
    self.pluck(:name).sort
  end

  def comments_desc
    comment_threads.includes(:user).order('created_at desc')
  end
end
