require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'sprockets/railtie'

# https://github.com/elastic/elasticsearch-rails/tree/master/elasticsearch-rails#activesupport-instrumentation
require 'elasticsearch/rails/instrumentation'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Transbucket
  class Application < Rails::Application
    # TODO include blocking ips for bad users
    # config.middleware.use Rack::Attack

    config.action_controller.page_cache_directory = "#{Rails.root}/public/page_cache"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = true
    config.active_support.cache_format_version = 7.1
    # Set the signing key before Rails initializes, preserving the existing
    # production/test values without consulting deprecated secrets.yml.
    config.secret_key_base = ENV['SECRET_KEY_BASE'] if ENV['SECRET_KEY_BASE'].present?
    config.secret_key_base = 'f607f528104f0200b0df7d08c353cc4458d1d943b066e25d0c922fbc786f47a8dcb33ccb9ebfaef7454b664bfbe5831e76dc3c8dbb7964b7c68edbff2d5fe813' if ENV['RAILS_ENV'] == 'test'
    # Rails' ruby schema dumper can't represent expression indexes (the
    # lower(username)/lower(email) functional indexes the login-lookup fix
    # depends on), so a plain `rake db:migrate` silently drops them from
    # schema.rb -- bit us twice in one night. structure.sql is generated via
    # pg_dump instead, which captures the database at the SQL level and
    # doesn't have this gap.
    config.active_record.schema_format = :sql

    # necessary for using bower-rails!
    config.assets.paths = config.assets.paths + [
      Rails.root.join('vendor', 'assets', 'bower_components'),
      Rails.root.join('vendor', 'assets', 'bower_components', 'jquery-ui', 'themes', 'smoothness', 'images'),
      Rails.root.join('vendor', 'assets', 'bower_components', 'tinymce', 'skins', 'lightgray', 'img'),
      Rails.root.join('vendor', 'assets', 'bower_components', 'tinymce', 'skins', 'lightgray', 'fonts')
    ]
    config.assets.precompile << 'tinymce/langs/*.js'

    config.generators do |g|
      g.test_framework :rspec,
        :fixtures => false,
        :view_specs => false,
        :helper_specs => false,
        :routing_specs => false,
        :controller_specs => true,
        :request_specs => true
    end
  end
end
