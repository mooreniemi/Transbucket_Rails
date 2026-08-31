# https://github.com/rails/rails/issues/34790#issuecomment-450502805
if RUBY_VERSION>='2.6.0'
  if Rails.version < '5'
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        # hack to avoid MonitorMixin double-initialize error. Ruby's
        # MonitorMixin has used @mon_data/@mon_data_owner_object_id (instead
        # of @mon_mutex/@mon_mutex_owner_object_id) since Ruby 2.7, and
        # `defined?` stays true even after assigning nil, so the ivars must
        # be removed outright to let #initialize re-run mon_initialize.
        remove_instance_variable(:@mon_data) if defined?(@mon_data)
        remove_instance_variable(:@mon_data_owner_object_id) if defined?(@mon_data_owner_object_id)
        remove_instance_variable(:@mon_mutex) if defined?(@mon_mutex)
        remove_instance_variable(:@mon_mutex_owner_object_id) if defined?(@mon_mutex_owner_object_id)
        initialize
      end
    end
  else
    puts "Monkeypatch for ActionController::TestResponse no longer needed"
  end
end
