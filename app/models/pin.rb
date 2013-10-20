class Pin < ActiveRecord::Base
  has_many :pin_images, :dependent => :destroy
  has_many :comments

  attr_accessible :description, :pin_images, :pin_images_attributes, :surgeon, :cost, :revision, :details, :procedure, :username, :id, :created_at

  accepts_nested_attributes_for :pin_images, :reject_if => proc {|attributes| attributes.all? {|k,v| v.blank?} }

  #validates :surgeon, presence: true
  #validates :procedure, presence: true
  #validates :pin_images, presence: true
  validates :user_id, presence: true

  belongs_to :user

  acts_as_commentable
  acts_as_votable

  def has_new_comments(user)
    @user = User.find(user).last_sign_in_at
    @comments = Comment.where('created_at > ? and commentable_id = ?', @user, self.id)
  end

  def flag_from(user)
    if self.votes.down.size >= 2 && self.published?
      self.review!
      return "Removed for review."
    else
      self.downvote_from(user)
      return "Flagged content."
    end
  end

  state_machine initial: :published do
    state :pending, value: "pending"
    state :published, value: "published"

    event :publish do
      transition nil => :published
      transition :pending => :published
    end

    event :review do
      transition :published => :pending
    end
  end

end
