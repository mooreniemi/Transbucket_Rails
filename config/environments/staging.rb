Rails.application.configure do
  # WARN: security vulnerability do NOT turn off
  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => ENV['HOSTNAME'] || "www.transbucket.com" }

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # TODO http://stackoverflow.com/a/36130406/1791856
  config.paperclip_defaults = {
    :storage => :s3,
    :s3_region => "us-east-1",
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET'],
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    },
    :url => ':s3_alias_url',
    :s3_host_alias => 'dwusg3ww9j123.cloudfront.net',
    :path => '/:class/:attachment/:id_partition/:style/:filename'
  }

  # see https://devcenter.heroku.com/articles/sendgrid#ruby-rails
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com',
    :enable_starttls_auto => true
  }
end
