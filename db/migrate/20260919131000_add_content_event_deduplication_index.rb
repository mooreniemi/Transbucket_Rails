class AddContentEventDeduplicationIndex < ActiveRecord::Migration
  def change
    add_index :content_events,
      [:visitor_hash, :content_type, :content_id, :event_type, :occurred_at],
      name: 'index_content_events_on_visitor_deduplication'
    add_index :content_events,
      [:user_id, :content_type, :content_id, :event_type, :occurred_at],
      name: 'index_content_events_on_user_deduplication'
  end
end
