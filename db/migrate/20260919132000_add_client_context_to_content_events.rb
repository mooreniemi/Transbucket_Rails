class AddClientContextToContentEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :content_events, :client_context, :jsonb, null: false, default: {}
  end
end
