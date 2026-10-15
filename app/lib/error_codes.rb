# Turns a record's validation errors into codes a client can map to its own
# copy, instead of sending English (or Rails-localized) sentences built from
# attribute names:
#
#   { email: [{ code: 'invalid' }], password: [{ code: 'too_short', count: 8 }] }
#
# Only the error type and numeric options (count) are sent -- never the value
# that failed, which for a password field would be the password.
module ErrorCodes
  OPTIONS = %i[count].freeze

  def self.for(record)
    record.errors.details.transform_values do |details|
      details.map do |detail|
        # A bare String as the type means a custom message with no type.
        code = detail[:error].is_a?(Symbol) ? detail[:error].to_s : 'invalid'
        { code: code }.merge(detail.slice(*OPTIONS))
      end
    end
  end
end
