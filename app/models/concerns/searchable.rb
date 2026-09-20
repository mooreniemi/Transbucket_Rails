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

    after_commit :enqueue_index_document, on: [:create, :update]
    after_commit :enqueue_delete_document, on: :destroy
  end

  class_methods do
    # Delayed Job serializes its receiver and arguments. Keep queued search
    # work portable across Rails/Ruby upgrades by storing only primitives.
    def index_document_async(index_name, document_id)
      document = find_by(id: document_id)
      return unless document

      document.__elasticsearch__.index_document
    end
    handle_asynchronously :index_document_async

    # A destroyed Active Record object cannot be serialized by delayed_job.
    # Pass the stable index name and document ID instead.
    def delete_document_async(index_name, document_id)
      __elasticsearch__.client.delete(index: index_name, id: document_id)
    end
    handle_asynchronously :delete_document_async
  end

  def enqueue_index_document
    self.class.index_document_async(self.class.index_name, id)
  end

  def enqueue_delete_document
    self.class.delete_document_async(self.class.index_name, id)
  end
end
