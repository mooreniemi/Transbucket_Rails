require 'rails_helper'

describe 'TinyMCE locale assets' do
  SUPPORTED_EDITOR_LOCALES = %w(de es fr it ja zh-CN zh-TW pt-BR nl pl ru tr vi ar).freeze

  it 'keeps a local language pack for every supported non-English locale' do
    SUPPORTED_EDITOR_LOCALES.each do |locale|
      path = Rails.root.join('vendor', 'assets', 'bower_components', 'tinymce', 'langs', "#{locale}.js")
      expect(File).to exist(path), "expected TinyMCE language pack #{path}"
    end
  end

  it 'precompiles nested TinyMCE language assets' do
    expect(Rails.application.config.assets.precompile).to include('tinymce/langs/*.js')
  end
end
