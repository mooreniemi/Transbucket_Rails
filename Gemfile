source 'https://rubygems.org'

gem 'rails', '4.1.4'

gem 'turbolinks'
gem 'bower-rails', '~> 0.7.3'

gem 'protected_attributes'

# for thinking sphinx
# gem 'mysql'
gem 'mysql2', '0.3.12b5'
gem 'activerecord-mysql-adapter'

gem 'pg'

gem 'will_paginate', '~> 3.0'
gem 'paperclip', '~> 3.0'

gem 'aws-sdk'
gem 'aws-s3'

gem 'figaro'

gem 'delayed_job_active_record'
gem 'tinymce-rails'

gem 'devise'
gem 'devise-encryptable'

gem 'state_machine'

gem 'rake-progressbar'

gem 'nested_form'
gem 'simple_form'

gem 'thinking-sphinx'
gem 'flying-sphinx'

gem 'htmlentities'
gem 'simple-rss'
gem 'meta-tags', :require => 'meta_tags'

gem 'acts_as_votable', '~> 0.7.1'
gem 'acts-as-taggable-on'
gem 'acts_as_commentable_with_threading'
gem 'ledermann-rails-settings', :require => 'rails-settings'
gem 'letsrate'

gem 'awesome_print'

gem 'font-awesome-sass'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-star-rating-rails'
gem 'jquery-multiselect-rails', :git => 'git://github.com/arojoal/jquery-multiselect-rails.git'
gem 'underscore-rails'

gem 'rack-block'

group :development, :local do
  gem 'thin'
  gem 'quiet_assets'
  gem 'meta_request'
  gem 'better_errors'
end

group :development, :test do
  gem 'rack-mini-profiler'
  gem 'bullet'
  gem 'binding_of_caller'
  gem 'guard'
  gem 'guard-livereload'
  gem 'pry-nav'
  gem 'pry-rails'
  gem 'pry-coolline'
end

group :test do
  gem 'faker'
  gem 'simplecov'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
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
  gem 'newrelic_rpm'
  gem 'unicorn'
end