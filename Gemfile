source 'https://rubygems.org'

# https://devcenter.heroku.com/articles/ruby-versions
ruby '3.1.6'

gem 'rails', '7.0.10'
# used for public areas of the site, see PagesController
gem 'actionpack-page_caching', '~> 1.2.2'

gem 'unicorn'
# Caches load-path lookups and compiled Ruby/YAML so boots (tests, rails
# runner, Heroku one-off dynos) are faster. Required from config/boot.rb.
gem 'bootsnap', require: false
gem 'turbolinks'
gem 'bower-rails', '~> 0.7.3'

# for ci
gem 'rspec_junit_formatter', '0.2.2'

# needs to be before ES
gem 'will_paginate', '~> 3.0'
gem 'will_paginate-bootstrap'

# FIXME: if using AWS
# gem 'faraday_middleware-aws-sigv4'
# elasticsearch-model/-rails have no version constraint of their own, so an
# unpinned `bundle update` can silently jump the client to the 8.x line --
# a different wire protocol/API generation that the ES 7.12.0 server pinned
# everywhere (CircleCI, docker-compose, staging/production) doesn't speak.
gem 'elasticsearch', '7.4.0'
gem 'elasticsearch-model', '7.1.0'
gem 'elasticsearch-rails'
# elasticsearch-transport pulls in faraday with no version constraint of its
# own, so an unpinned `bundle update` would silently jump to faraday 2.x --
# a breaking major version this old elasticsearch-transport (7.4.0) was never
# written against. Pin to the 1.x line so patch/security updates land safely.
gem 'faraday', '~> 1.10'

gem 'active_model_serializers'

gem 'pg', '~> 1.5'
gem 'delayed_job_active_record'

# Maintained fork of thoughtbot's Paperclip (abandoned in 2018), from Kreeti.
# It stores files the same way, and uses the current S3 SDK instead of the
# unmaintained aws-sdk v2.
gem 'kt-paperclip', '~> 8.0'
gem 'aws-sdk-s3', '~> 1'
gem 'json', '2.6.3'
gem 'webrick'

# for slug ids
gem 'friendly_id', '~> 5.1.0' # Note: You MUST use 5.0.0 or greater for Rails 4.0+

# for managing environment variables
gem 'figaro', '~> 1.3'

# Rails 6.1's latest Zeitwerk supports Ruby 3.1; newer Zeitwerk releases
# require the later Ruby upgrade planned after this Rails step.
gem 'zeitwerk', '2.6.18'

# for i18n, pulls out header
gem 'http_accept_language'
# Rails-i18n follows Rails' major version: the 5.x line caps Railties below 6.
gem 'rails-i18n', '~> 7.0'
# Nokogiri 1.19 requires Ruby 3.2. Keep the current security-patched release
# until the planned Ruby 3.3 upgrade.
gem 'nokogiri', '1.18.10'
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
	# Faker 1.x passes I18n options positionally and cannot run with Rails 6's
	# I18n 1.x. 3.5 remains compatible with the current Ruby 3.1 runtime.
	gem 'faker', '3.5.2', :require => false
gem 'zip-codes'

gem 'nested_form'
gem 'simple_form'
gem 'reform', '2.6.2'
gem 'reform-rails', '0.3.1'

gem 'phony_rails', '~> 0.15'

# pin submission wysiwyg
gem 'tinymce-rails', '4.2.6'

gem 'htmlentities'
gem 'simple-rss'
gem 'meta-tags', :require => 'meta_tags'

gem 'acts_as_votable', '~> 0.7.1'
# Pinned rather than left open: an unpinned `bundle update` drifts this
# several major versions further (through real tag_list API changes) with
# no Rails-5 need to do so. Versions 4.0.0 through 6.5.0 all pass a plain
# Hash positionally to `belongs_to :tagger, {polymorphic: true, ...}` --
# legal under Rails 4.2's belongs_to(name, scope=nil, options={}), but
# Rails 5.2's belongs_to(name, scope=nil, **options) binds that Hash to
# `scope` instead, raising NoMethodError on Hash#arity. Fixed upstream in
# 7.0.0 (real `polymorphic:, optional:` keyword syntax).
gem 'acts-as-taggable-on', '9.0.1'
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
	gem 'better_errors'
end

group :development, :test do
  gem 'matrix'
  gem 'stackprof'
  gem 'ruby-prof', '~> 1.4'
	gem 'rack-mini-profiler', '~> 3.1'
  # gem 'flamegraph' # for rack-mini-profiler
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rspec-benchmark'
  gem 'parallel_tests'
	gem 'bullet', '~> 7.0.7'
  # NOTE: with spring breaks rails console, so don't use it
	# gem 'binding_of_caller'
	gem 'guard'
	gem 'guard-livereload'
	gem 'pry-rescue'
	gem 'pry-nav'
	gem 'pry-rails'
	gem 'pry-coolline'
end

group :test do
	gem 'simplecov', :require => false
	gem 'database_cleaner', '~> 2.1'
  # 3.9 calls Rails 6's template compiler with its Rails 5 signature.
  gem 'rspec-rails', '5.1.2'
	# assigns/assert_template were extracted out of Rails core in 5.0.
	gem 'rails-controller-testing'
	gem 'factory_bot', '6.5.0'
	gem 'capybara', '3.40.0'
  gem 'capybara-email'
	gem 'selenium-webdriver', '4.8.1'
	gem 'guard-rspec'
	gem 'launchy'
	gem 'rspec-console'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
	gem 'sass-rails', '~> 5.0'
	gem 'coffee-rails', '~> 5.0'
	# other versions yanked https://rubygems.org/gems/bootstrap-sass/versions
	gem 'bootstrap-sass', '3.4.1'
	gem 'autoprefixer-rails'
	gem 'uglifier', '>= 1.0.3'
end

group :production do
	# for assets, see https://devcenter.heroku.com/articles/rails-4-asset-pipeline
	gem 'rails_12factor'
# The pre-Rails-5 agent crashes while loading the Rails 5 framework adapter.
gem 'newrelic_rpm', '10.7.1'
# 2.1.32 instruments Active Record with Rails 4 method signatures. 4.0.4
# includes the agent's Rails 5.2 and Ruby 3 compatibility fixes while retaining
# the production Scout telemetry configured through SCOUT_KEY/SCOUT_MONITOR.
gem 'scout_apm', '4.0.4'
end
