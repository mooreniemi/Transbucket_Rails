class AddOutreachSentAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :never_signed_in_outreach_sent_at, :datetime
  end
end
