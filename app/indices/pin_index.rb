ThinkingSphinx::Index.define :pin, :with => :active_record do
  indexes surgeon(:last_name), :as => :surgeon, :sortable => true
  indexes procedure(:name), :as => :procedure, :sortable => true
  indexes username, :as => :user, :sortable => true

  has user_id, surgeon_id, procedure_id, created_at, updated_at
end