class Pin < ActiveRecord::Base
  has_many :pin_images, :dependent => :destroy
  has_many :comments

  attr_accessible :description, :pin_images, :pin_images_attributes, :surgeon, :cost, :revision, :details, :procedure, :username, :id, :created_at

  accepts_nested_attributes_for :pin_images, :reject_if => proc {|attributes| attributes.all? {|k,v| v.blank?} }

  validates :surgeon, presence: true
  validates :procedure, presence: true
  #validates :pin_images, presence: true
  validates :user_id, presence: true

  belongs_to :user

  acts_as_commentable

  def has_new_comments(user)
    @user = User.find(user).last_sign_in_at
    @comments = Comment.where('created_at > ? and commentable_id = ?', @user, self.id)
  end

end
