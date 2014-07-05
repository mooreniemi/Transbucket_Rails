Transbucket::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false

  #config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  config.action_mailer.perform_deliveries = true

  config.action_mailer.delivery_method = :smtp

  ENV['SENDGRID_USERNAME'] = "app15705776@heroku.com";
  ENV['SENDGRID_PASSWORD'] = "4d322jid";

  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com',
    :enable_starttls_auto => true
  }

  config.action_mailer.default_url_options = {
    :host => "transbucket.com"
  }

  config.middleware.use Rails::Rack::LogTailer

  config.log_level = ENV["LOG_LEVEL"].to_sym if ENV["LOG_LEVEL"]

  Paperclip.options[:command_path] = '/usr/local/bin/identify'

  config.after_initialize do
    Bullet.enable = true
    #Bullet.alert = true
    #Bullet.bullet_logger = true
    #Bullet.console = true
    #Bullet.growl = true
    #Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
    #                :password => 'bullets_password_for_jabber',
    #                :receiver => 'your_account@jabber.org',
    #                :show_online_status => true }
    Bullet.rails_logger = true
    #Bullet.airbrake = true
    #Bullet.add_footer = true
  end

end
