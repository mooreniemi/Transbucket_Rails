module Searchable
  extend ActiveSupport::Concern
  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # NOTE: we want to make sure we don't create clashing indices
    index_name {
      [
        Rails.env.underscore,
        self.ancestors.first.name.underscore.pluralize
      ].join('_')
    }
  end
end
