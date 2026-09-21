require 'rails_helper'

describe 'migration compatibility' do
  it 'versions every migration for Rails 5' do
    unversioned = Dir[Rails.root.join('db/migrate/*.rb')].select do |path|
      File.read(path).match?(/<\s*ActiveRecord::Migration(?:\s|$)/)
    end

    expect(unversioned).to be_empty
  end
end
