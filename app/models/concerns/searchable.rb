module Searchable
  extend ActiveSupport::Concern
  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # NOTE: we want to make sure we don't create clashing indices
    # we don't use Rails.env directly because staging uses same env
    index_name {
      [
        ENV['INDEX_PREFIX'] || Rails.env.underscore,
        self.ancestors.first.name.underscore.pluralize
      ].join('_')
    }
  end
end
