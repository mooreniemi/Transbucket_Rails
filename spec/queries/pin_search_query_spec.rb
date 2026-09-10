require 'spec_helper'
require_relative '../../app/queries/pin_search_query'

describe PinSearchQuery do
  describe '.all_xfields' do
    it 'keeps the full text query and adds a prefix match for procedure names' do
      query = described_class.all_xfields('orchi')

      expect(query[:query][:bool][:minimum_should_match]).to eq(1)

      clauses = query[:query][:bool][:should]
      expect(clauses).to include(
        hash_including(
          multi_match: hash_including(
            query: 'orchi',
            type: 'cross_fields',
            operator: 'and'
          )
        )
      )

      expect(clauses).to include(
        hash_including(
          match_phrase_prefix: {
            'procedure.name' => hash_including(
              query: 'orchi',
              analyzer: 'english'
            )
          }
        )
      )

      expect(clauses).to include(
        hash_including(
          match_phrase_prefix: {
            'procedure.aliases' => hash_including(
              query: 'orchi',
              analyzer: 'standard'
            )
          }
        )
      )

      fields = clauses.first[:multi_match][:fields]
      expect(fields).to include('procedure.aliases')
    end
  end
end
