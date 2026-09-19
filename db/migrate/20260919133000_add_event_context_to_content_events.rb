class AddEventContextToContentEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :content_events, :event_context, :jsonb, null: false, default: {}
  end
end
