require 'faker' # gemfile marks faker require: false so production boot skips it; factories need it loaded before FactoryBot's after-initialize hook runs

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Keep the existing test cookie/signing key while avoiding the deprecated
  # Rails.application.secrets fallback used by Rails 7.1.
  config.secret_key_base = 'f607f528104f0200b0df7d08c353cc4458d1d943b066e25d0c922fbc786f47a8dcb33ccb9ebfaef7454b664bfbe5831e76dc3c8dbb7964b7c68edbff2d5fe813'

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = false

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_files = true
  config.static_cache_control = 'public, max-age=3600'
  # Browser specs must resolve the current source assets, not a stale manifest
  # left by a previous precompile.
  config.assets.resolve_with = [:environment]
  config.assets.paths = config.assets.paths + [TinyMCE::Rails::Engine.root.join('vendor', 'assets', 'javascripts', 'tinymce', 'skins', 'lightgray')]

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: "transbucket.staging.com" }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

end
