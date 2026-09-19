class AddClientContextToContentEvents < ActiveRecord::Migration
  def change
    add_column :content_events, :client_context, :jsonb, null: false, default: {}
  end
end
