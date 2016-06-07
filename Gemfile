source 'https://rubygems.org'

# https://devcenter.heroku.com/articles/ruby-versions
ruby '2.2.2'

gem 'rails', '4.2.1'
# used for public areas of the site, see PagesController
gem 'actionpack-page_caching'

gem 'unicorn'
gem 'turbolinks'
gem 'bower-rails', '~> 0.7.3'

gem 'protected_attributes'

# for ci
gem 'rspec_junit_formatter', '0.2.2'

# for thinking sphinx (search functionality)
gem 'mysql2', '~> 0.4.4'
gem 'activerecord-mysql-adapter'
gem 'thinking-sphinx'
gem 'flying-sphinx'

gem 'active_model_serializers'

gem 'pg'
gem 'delayed_job_active_record'

gem 'will_paginate', '~> 3.0'
gem 'will_paginate-bootstrap'

gem 'paperclip', '~> 4.2'
gem 'aws-sdk'

# for managing environment variables
gem 'figaro'

gem 'devise'
gem 'devise-encryptable'

gem 'aasm'
gem 'fuzzy_match'

# kept at top level so rake tasks can use
# in any environment
gem 'rake-progressbar'
gem 'awesome_print'
# we use Faker to create junk data sometimes on staging
gem 'faker'

gem 'nested_form'
gem 'simple_form'
gem 'reform'
gem 'reform-rails'

gem 'ledermann-rails-settings', :require => 'rails-settings'

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

# TODO blocking ips, bots, etc
# gem 'rack-attack'

group :development do
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
  gem 'rspec-benchmark'
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
	gem 'poltergeist'
	gem 'guard-rspec'
	gem 'launchy'
	gem 'rspec-console'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
	gem 'sass-rails', '4.0.3'
	gem 'coffee-rails', '~> 4.0.0'
	gem 'bootstrap-sass', '~> 3.2.0'
	gem 'autoprefixer-rails'
	gem 'uglifier', '>= 1.0.3'
end

group :production do
	# for assets, see https://devcenter.heroku.com/articles/rails-4-asset-pipeline
	gem 'rails_12factor'
	gem 'newrelic_rpm'
end
