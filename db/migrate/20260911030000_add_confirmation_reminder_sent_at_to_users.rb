class AddConfirmationReminderSentAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :confirmation_reminder_sent_at, :datetime
  end
end
