ThinkingSphinx::Index.define :pin, :with => :active_record do
  indexes surgeon, :sortable => true
  indexes procedure, :sortable => true
  indexes username, :as => :user, :sortable => true

  has user_id, created_at, updated_at
end