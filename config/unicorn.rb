# https://devcenter.heroku.com/articles/rails-unicorn
# note that trapping signals can cause unicorn to hang on exit
# see http://stackoverflow.com/a/20315864

# A single 512 MB Heroku dyno cannot safely hold three eager-loaded Rails
# workers. Larger deployments can explicitly opt into more via WEB_CONCURRENCY.
worker_processes Integer(ENV.fetch("WEB_CONCURRENCY", 1))
timeout 15
preload_app true

if ENV['RAILS_ENV'] != 'production'
  require 'fileutils'
  FileUtils.mkdir_p 'tmp/pids'
  pid "tmp/pids/unicorn.pid"
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
