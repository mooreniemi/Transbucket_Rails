class User < ActiveRecord::Base
  belongs_to :gender
  has_one :preference
  has_many :trust_grants, class_name: 'UserTrustGrant', dependent: :destroy
  has_many :granted_trust_grants, class_name: 'UserTrustGrant', foreign_key: :granted_by_user_id
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

  # Pronouns are picked from PRONOUN_PRESETS or typed in the same "they/them"
  # shape. The form's select posts CUSTOM_PRONOUNS when "Other" is chosen and
  # the typed text arrives in pronouns_custom. NULL means "not chosen": pins then
  # fall back to the pronouns implied by the user's gender (see PinsHelper).
  PRONOUN_PRESETS = %w[
    she/her he/him they/them it/its she/they he/they they/she they/he
    any/all xe/xem ze/hir ze/zir fae/faer ey/em
  ].freeze
  CUSTOM_PRONOUNS = 'custom'.freeze
  PRONOUNS_FORMAT = %r{\A[[:alpha:]'-]{1,15}(?:/[[:alpha:]'-]{1,15}){1,3}\z}
  PRONOUNS_MAX_LENGTH = 40
  attr_accessor :pronouns_custom
  before_validation :normalize_pronouns
  validate :pronouns_shape

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

  def normalize_pronouns
    raw = pronouns == CUSTOM_PRONOUNS ? pronouns_custom : pronouns
    self.pronouns = raw.to_s.strip.downcase.gsub(%r{\s*[/／⁄∕]\s*}, '/').presence
  end

  # :base so the message reads as a whole sentence in any language, instead of
  # being prefixed with the (English) attribute name.
  def pronouns_shape
    return if pronouns.blank?
    return if pronouns.length <= PRONOUNS_MAX_LENGTH && pronouns.match?(PRONOUNS_FORMAT)

    errors.add(:base, I18n.t('public.auth.pronouns_invalid'))
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

  def trust_tier
    return @trust_tier if defined?(@trust_tier_loaded) && @trust_tier_loaded

    # Pin and procedure pages preload this association for comment authors.
    # Fall back to one indexed query rather than one EXISTS query per role.
    trust_grants_association = association(:trust_grants)
    grants = if trust_grants_association.loaded?
      trust_grants_association.target.select(&:active?)
    else
      trust_grants.active.to_a
    end
    @trust_tier = UserTrustGrant::KINDS.reverse.find do |kind|
      grants.any? { |grant| grant.kind == kind }
    end
    @trust_tier_loaded = true
    @trust_tier
  end

  def contributor?
    trust_tier.present?
  end

  def moderator?
    return true if admin?

    trust_tier == 'moderator'
  end

  def grant_trust!(kind, granted_by: nil, internal_note: nil)
    raise ArgumentError, "Unknown trust kind: #{kind}" unless UserTrustGrant::KINDS.include?(kind)

    grant = trust_grants.where(kind: kind).first_or_initialize
    grant.assign_attributes(
      source: granted_by.present? ? 'moderator' : 'automatic',
      granted_by: granted_by,
      internal_note: internal_note,
      granted_at: Time.current,
      revoked_at: nil
    )
    grant.save!
    # `where(...).first_or_initialize` can populate an association target
    # without marking the Rails 4 collection as loaded. Reset unconditionally
    # so the next role lookup cannot read that stale partial target.
    association(:trust_grants).reset
    @trust_tier = nil
    @trust_tier_loaded = false
    grant
  end

  private

  def set_preference
    # Build through the association so a just-created user can use its
    # preference immediately (rather than having an existing row but a stale
    # cached `user.preference == nil` until the next request).
    build_preference.save! if preference.nil?
  end
end
