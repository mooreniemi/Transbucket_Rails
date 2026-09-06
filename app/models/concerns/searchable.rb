module Searchable
  extend ActiveSupport::Concern
  included do
    include Elasticsearch::Model

    # NOTE: we want to make sure we don't create clashing indices
    # we don't use Rails.env directly because staging uses same env
    index_name {
      [
        ENV['INDEX_PREFIX'] || Rails.env.underscore,
        self.ancestors.first.name.underscore.pluralize
      ].join('_')
    }

    after_commit :index_document_async, on: [:create, :update]
    after_commit :delete_document_async, on: :destroy
    handle_asynchronously :index_document_async
    handle_asynchronously :delete_document_async
  end

  def index_document_async
    __elasticsearch__.index_document
  end

  def delete_document_async
    __elasticsearch__.delete_document
  end
end
