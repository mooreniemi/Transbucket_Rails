module Searchable
	extend ActiveSupport::Concern
	included do
		include Elasticsearch::Model
		include Elasticsearch::Model::Callbacks

    # If you want to make them per env...
		# index_name [Rails.application.engine_name, Rails.env].join('_')
	end
end
