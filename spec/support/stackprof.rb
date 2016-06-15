# https://gist.github.com/leonelgalan/a613c1d8e293f3219327
# run stackprof on whole suite

if ENV['STACKPROF']
  require 'stackprof'

  RSpec.configure do |config|
    config.before :suite do
      StackProf.start(mode: ENV['STACKPROF'].to_sym, interval: 1000, out: "tmp/stackprof-#{ENV['STACKPROF']}-transbucket.dump")
    end

    config.after :suite do
      StackProf.stop
      StackProf.results
    end
  end
end

# usage: STACKPROF=cpu rspec
# bundle exec stackprof tmp/stackprof-cpu-*.dump --text
