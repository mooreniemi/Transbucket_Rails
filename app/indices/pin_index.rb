ThinkingSphinx::Index.define :pin, :with => :active_record do
  indexes procedure(:name), :as => :procedure, :sortable => true
  indexes complications(:name), :as => :complication, :sortable => true

  indexes surgeon(:last_name), :as => :surgeon, :sortable => true
  indexes username, :as => :user, :sortable => true

  has user_id, surgeon_id, procedure_id, created_at, updated_at
end
