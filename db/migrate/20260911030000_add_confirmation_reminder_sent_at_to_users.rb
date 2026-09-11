class AddConfirmationReminderSentAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_reminder_sent_at, :datetime
  end
end
