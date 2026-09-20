class User < ActiveRecord::Base
  belongs_to :gender
  has_one :preference
  after_create :set_preference

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :confirmable, :validatable, :authentication_keys => [:login], :timeout_in => 180.minutes

  # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password_confirmation, :remember_me, :name, :gender_id, :username, :id, :created_at, :updated_at, :login, :md5, :password, :settings
  # attr_accessible :title, :body
  attr_accessor :login

  # Virtual, not persisted -- set by UnconfirmedReminderService right before
  # calling send_confirmation_instructions so the mailer view (which only
  # has access to @resource, not arbitrary opts) can tell a reminder apart
  # from the original confirmation email.
  attr_accessor :confirmation_reminder

  validates :username,
    :uniqueness => {
      :case_sensitive => false
    }

  has_many :pins

  acts_as_voter

  # Split into two single-column lookups rather than one OR'd query --
  # each hits its own functional index (index_users_on_lower_username /
  # index_users_on_lower_email) directly. The combined OR, together with
  # the implicit ORDER BY id from `.first`, made Postgres walk users_pkey
  # in id order filtering row-by-row instead of using either index, so a
  # login for a nonexistent user (or a bot/credential-stuffing attempt)
  # scanned the entire users table.
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup.to_hash
    if login = conditions.delete(:login)
      value = login.downcase
      where(conditions).where(["lower(username) = :value", { :value => value }]).first ||
        where(conditions).where(["lower(email) = :value", { :value => value }]).first
    else
      where(conditions).first
    end
  end

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
    # Build through the association so a just-created user can use its
    # preference immediately (rather than having an existing row but a stale
    # cached `user.preference == nil` until the next request).
    build_preference.save! if preference.nil?
  end
end
