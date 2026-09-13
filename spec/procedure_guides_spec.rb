require 'spec_helper'
require 'yaml'

describe 'procedure guides' do
  HIGH_PRIORITY_PROCEDURES = [
    'abdominal flap phalloplasty',
    'scrotoplasty',
    'scrotectomy',
    'laparoscopic hysterectomy',
    'vaginectomy',
    'monsplasty',
    'glansplasty',
    'tracheal shave',
    'alt phalloplasty'
  ].freeze

  it 'keeps source-backed summaries and related links for high-priority procedures' do
    guides = YAML.load_file(File.expand_path('../config/procedure_guides.yml', __dir__))

    HIGH_PRIORITY_PROCEDURES.each do |name|
      guide = guides.fetch(name)
      expect(guide.fetch('summary')).not_to be_empty
      expect(guide.fetch('summary')).not_to match(/view .* submissions/i)
      expect(guide.fetch('sources')).not_to be_empty
      expect(guide.fetch('sources')).to all(include('name', 'url'))
      expect(guide.fetch('sources').map { |source| source.fetch('url') }).to all(match(%r{\Ahttps://}))
      expect(guide.fetch('related_procedures')).not_to be_empty
    end
  end
end
