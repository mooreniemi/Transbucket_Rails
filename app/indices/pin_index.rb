ThinkingSphinx::Index.define :pin, :with => :active_record do
  indexes details
  indexes description

  indexes pin_images(:caption), :as => :caption, :sortable => true
  indexes procedure(:name), :as => :procedure, :sortable => true
  indexes complications(:name), :as => :complication, :sortable => true

  # TODO: can we grab author comments somehow as well?

  indexes surgeon(:last_name), :as => :surgeon, :sortable => true
  indexes username, :as => :user, :sortable => true

  has user_id, surgeon_id, procedure_id, created_at, updated_at
end
