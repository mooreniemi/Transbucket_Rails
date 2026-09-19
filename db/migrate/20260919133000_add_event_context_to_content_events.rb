class AddEventContextToContentEvents < ActiveRecord::Migration
  def change
    add_column :content_events, :event_context, :jsonb, null: false, default: {}
  end
end
