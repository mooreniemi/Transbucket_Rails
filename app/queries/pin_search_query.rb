class PinSearchQuery
  DEFAULT_OPTIONS = { sort: [ { updated_at: { order: 'desc' } } ] }

  # see Pin model for how the fields were indexed if you need to adjust the below
  # also https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html
  # https://github.com/elastic/elasticsearch-rails/tree/master/elasticsearch-model#searching
  def self.all_xfields(search_terms, operator: "and")
    return {
      query:
      { multi_match:
        { query: search_terms,
          fields: [
            "surgeon.pretty_name",
            "procedure.name",
            "procedure.description",
            "description",
            "details",
            "pin_images.caption",
            "complications.name"
          ],
          type: "cross_fields",
          operator: operator
        }
      }
    }
  end
end
