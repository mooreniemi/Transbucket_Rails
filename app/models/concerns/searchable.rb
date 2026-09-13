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
    after_commit :enqueue_delete_document, on: :destroy
    handle_asynchronously :index_document_async
  end

  class_methods do
    # A destroyed Active Record object cannot be serialized by delayed_job.
    # Pass the stable index name and document ID instead.
    def delete_document_async(index_name, document_id)
      __elasticsearch__.client.delete(index: index_name, id: document_id)
    end
    handle_asynchronously :delete_document_async
  end

  def index_document_async
    __elasticsearch__.index_document
  end

  def enqueue_delete_document
    self.class.delete_document_async(self.class.index_name, id)
  end
end
