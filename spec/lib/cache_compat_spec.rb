require 'rails_helper'

describe 'Rails 5 cache compatibility' do
  around do |example|
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = original_cache
  end

  it 'supports cache writes and fetches with options' do
    expect(Rails.cache.write('compatibility-key', 'stored', expires_in: 1.minute)).to eq(true)
    expect(Rails.cache.read('compatibility-key')).to eq('stored')
    expect(Rails.cache.fetch('fetch-key', expires_in: 1.minute) { 'fetched' }).to eq('fetched')
    expect(Rails.cache.fetch('fetch-key', expires_in: 1.minute) { 'unexpected' }).to eq('fetched')
  end
end
