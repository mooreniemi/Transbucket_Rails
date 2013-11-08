class Preference < ActiveRecord::Base
  attr_accessible :user_id, :safe_mode, :notification
  belongs_to :user
end
