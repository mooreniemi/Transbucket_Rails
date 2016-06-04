source 'https://rubygems.org'

gem 'rails', '3.2.12'

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
gem 'jquery-ui-rails'
gem 'jquery-rails'
gem 'jquery-star-rating-rails'
gem 'jquery-multiselect-rails', :git => 'git://github.com/arojoal/jquery-multiselect-rails.git'
gem 'underscore-rails'

gem 'rack-block'

group :development, :local do
  gem 'thin'
  gem 'rack-mini-profiler'
  gem 'bullet'
  gem 'quiet_assets'
  gem 'meta_request','0.2.5'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard'
  gem 'guard-livereload'
end

group :development, :test do
  gem 'pry-nav'
  gem 'pry-rails'
  gem 'pry-coolline'
end

group :test do
  gem 'simplecov', '~> 0.7.1'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'mocha'
end

group :production do
  gem 'newrelic_rpm'
  gem 'unicorn'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'bootstrap-sass', '~> 2.2.2.0'

  gem 'uglifier', '>= 1.0.3'
end
