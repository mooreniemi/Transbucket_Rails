# https://devcenter.heroku.com/articles/rails-unicorn
# note that trapping signals can cause unicorn to hang on exit
# see http://stackoverflow.com/a/20315864

worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true
pid "tmp/pids/unicorn.pid"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
