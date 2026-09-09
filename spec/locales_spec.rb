require 'spec_helper'
require 'yaml'

describe 'application locales' do
  SUPPORTED_LOCALES = %w(en de es fr it ja zh-CN zh-TW pt-BR nl pl ru tr vi ar).freeze
  REQUIRED_KEYS = %w(site.description homepage.title homepage.intro header.search footer.discord_prefix locale.label account_menu.login filter_menu.apply filter_menu.clear filter_menu.scope filter_menu.procedure filter_menu.surgeon directory.procedures_title directory.procedures_intro directory.surgeons_title directory.surgeons_intro directory.submissions directory.submissions_intro directory.recent_submissions directory.search_results directory.search_description directory.name directory.average_satisfaction directory.average_sensation directory.discussion_threads directory.register_to_see_more newsfeed.title newsfeed.description newsfeed.date newsfeed.entries.procedure_cleanup newsfeed.entries.prefix_search newsfeed.entries.discord_invite newsfeed.entries.locales).freeze
  REQUIRED_FILTER_SCOPES = %w(ftm mtf bottom top need_category).freeze

  def merge_translations(left, right)
    left.merge(right) do |_key, old_value, new_value|
      old_value.is_a?(Hash) && new_value.is_a?(Hash) ? merge_translations(old_value, new_value) : new_value
    end
  end

  before do
    @translations = Dir[File.expand_path('../config/locales/*.yml', __dir__)].sort.reduce({}) do |translations, file|
      merge_translations(translations, YAML.load_file(file))
    end
  end

  it 'defines the first-pass public UI keys for every supported locale' do
    SUPPORTED_LOCALES.each do |locale|
      REQUIRED_KEYS.each do |key|
        value = key.split('.').reduce(@translations.fetch(locale)) { |hash, part| hash.fetch(part) }
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
      REQUIRED_FILTER_SCOPES.each do |scope|
        value = @translations.fetch(locale).fetch('filter_scopes').fetch(scope)
        expect(value).not_to be_nil
        expect(value).not_to eq('')
      end
    end
  end
end
