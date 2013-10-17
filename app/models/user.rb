class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:login]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password_confirmation, :remember_me, :name, :gender, :username, :id, :created_at, :updated_at, :login, :md5, :password
  # attr_accessible :title, :body
  attr_accessor :login

  validates :username,
    :uniqueness => {
      :case_sensitive => false
    }

  has_many :pins

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
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
end