source 'https://rubygems.org'

# https://devcenter.heroku.com/articles/ruby-versions
ruby '2.6.6'

gem 'rails', '4.2.8'
# used for public areas of the site, see PagesController
gem 'actionpack-page_caching'

gem 'unicorn'
gem 'turbolinks'
gem 'bower-rails', '~> 0.7.3'

gem 'protected_attributes'

# for ci
gem 'rspec_junit_formatter', '0.2.2'

# needs to be before ES
gem 'will_paginate', '~> 3.0'
gem 'will_paginate-bootstrap'

# FIXME: if using AWS
# gem 'faraday_middleware-aws-sigv4'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

gem 'active_model_serializers'

gem 'pg'
gem 'delayed_job_active_record'

gem 'paperclip', '~> 5.2.0'
gem 'aws-sdk'

# for slug ids
gem 'friendly_id', '~> 5.1.0' # Note: You MUST use 5.0.0 or greater for Rails 4.0+

# for managing environment variables
gem 'figaro'

# for i18n, pulls out header
gem 'http_accept_language'
gem 'rails-i18n', '~> 4.0'
gem 'i18n_generators'

# for authentication
gem 'bcrypt', '~> 3.1.13'
gem 'devise'
gem 'devise-i18n'
gem 'devise-encryptable'

gem 'aasm'
gem 'fuzzy_match'

# kept at top level so rake tasks can use
# in any environment
gem 'rake-progressbar'
gem 'awesome_print'
# we use Faker to create junk data sometimes on staging
gem 'faker'
gem 'zip-codes'

gem 'nested_form'
gem 'simple_form'
gem 'reform'
gem 'reform-rails'

gem 'phony_rails'

# pin submission wysiwyg
gem 'tinymce-rails'

gem 'htmlentities'
gem 'simple-rss'
gem 'meta-tags', :require => 'meta_tags'

gem 'acts_as_votable', '~> 0.7.1'
gem 'acts-as-taggable-on'
gem 'acts_as_commentable_with_threading'
gem 'letsrate'

gem 'font-awesome-rails'

gem 'sitemap_generator'

# TODO blocking ips, bots, etc
# gem 'rack-attack'

# in some environments we turn "down" logging
gem 'lograge'

group :development do
  gem 'brakeman', :require => false
  gem 'any_login'
	gem 'letter_opener'
	gem 'seed_dump'
	gem 'thin'
	gem 'quiet_assets'
	gem 'meta_request'
	gem 'better_errors'
end

group :development, :test do
  gem 'stackprof'
  gem 'ruby-prof'
	gem 'rack-mini-profiler'
  # gem 'flamegraph' # for rack-mini-profiler
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rspec-benchmark'
  gem 'parallel_tests'
	gem 'bullet'
	gem 'binding_of_caller'
	gem 'guard'
	gem 'guard-livereload'
	gem 'pry-rescue'
	gem 'pry-nav'
	gem 'pry-rails'
	gem 'pry-coolline'
end

group :test do
	gem 'simplecov', :require => false
	gem 'database_cleaner'
	gem 'rspec-rails'
	gem 'factory_girl_rails'
	gem 'capybara'
  gem 'capybara-email'
	gem 'selenium-webdriver'
	gem 'guard-rspec'
	gem 'launchy'
	gem 'rspec-console'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
	gem 'sass-rails', '4.0.3'
	gem 'coffee-rails', '~> 4.0.0'
	# other versions yanked https://rubygems.org/gems/bootstrap-sass/versions
	gem 'bootstrap-sass', '3.4.1'
	gem 'autoprefixer-rails'
	gem 'uglifier', '>= 1.0.3'
end

group :production do
	# for assets, see https://devcenter.heroku.com/articles/rails-4-asset-pipeline
	gem 'rails_12factor'
	gem 'newrelic_rpm'
  gem 'scout_apm'
end
