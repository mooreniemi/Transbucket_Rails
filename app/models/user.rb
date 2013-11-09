class User < ActiveRecord::Base
  has_settings do |s|
    s.key :view, :defaults => { :safe_mode => false }
    s.key :contact,  :defaults => { :notification => true }
  end

  has_one :preference
  after_create :set_preference

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, :validatable, :authentication_keys => [:login]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password_confirmation, :remember_me, :name, :gender, :username, :id, :created_at, :updated_at, :login, :md5, :password, :settings
  # attr_accessible :title, :body
  attr_accessor :login

  validates :username,
    :uniqueness => {
      :case_sensitive => false
    }

  has_many :pins

  acts_as_voter

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  #TODO figure out what is actually going on here
  def legacy_password_hash=(password)
    self.md5
  end

  def valid_password?(password)
    if self.md5.present?
      if ::Digest::MD5.hexdigest(password) == self.md5
        self.password = password
        self.md5 = nil
        self.save(:validate => false)
        true
      else
        false
      end
    else
        super
    end
  end

  def reset_password!(*args)
    self.legacy_password_hash = nil
    super
  end

  private

  def set_preference
    Preference.new(user_id: self.id).save if self.preference.nil?
  end
end