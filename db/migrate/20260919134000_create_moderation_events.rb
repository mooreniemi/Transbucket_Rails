class CreateModerationEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :moderation_events do |t|
      t.integer :user_id
      t.string :action, null: false
      t.string :content_type, null: false
      t.integer :content_id, null: false
      t.datetime :occurred_at, null: false
    end

    add_index :moderation_events, [:content_type, :content_id, :occurred_at], name: 'index_moderation_events_on_content_time'
    add_index :moderation_events, [:action, :occurred_at]
    add_index :moderation_events, [:user_id, :action, :occurred_at], name: 'index_moderation_events_on_user_action_time'
  end
end
