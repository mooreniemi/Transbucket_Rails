
												 _______
										 _.-()______)-._
									 .'               '.
									/                   \
								 :      _________      :
								 |.--'''         '''--.|
								 (                     )
								 :'--..._________...--':
								 :                     :
									:                   :
									:                   :
									 :                 :
									 :                 :
										:               :
										:               :
										 :             :
							 jrei  :_           _:
											 '''-----'''


Transbucket.com (Transbucket_Rails)
===================================

Transbucket.com is a photo-sharing website for transgender patients. We have roughly 70k users, and average 1000 uniques per month. We're not a huge site, but we do have active users that rely on us. And we're the only site without any profit agenda: this site is by and for the community. We welcome [contributions](https://github.com/mooreniemi/Transbucket_Rails/issues).

The TL;DR of technical specs is: Rails 4.2.6 (in Ruby 2.2.3), using [bower_rails](https://github.com/rharriso/bower-rails) to manage Javascript dependencies, on Postgres database for storage, and with Sphinx indexing for search.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [setup](#setup)
  - [database setup](#database-setup)
    - [mysql](#mysql)
    - [postgres](#postgres)
- [run environments](#run-environments)
  - [local](#local)
  - [ci](#ci)
  - [staging](#staging)
  - [production](#production)
  - [tests](#tests)
    - [parallel tests](#parallel-tests)
    - [performance testing](#performance-testing)
  - [static analysis](#static-analysis)
  - [profiling](#profiling)
    - [ruby-prof example](#ruby-prof-example)
    - [stackprof example](#stackprof-example)
- [caching](#caching)
- [search](#search)
- [running scheduled jobs / async execution](#running-scheduled-jobs--async-execution)
- [more help](#more-help)
- [contact](#contact)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->
# setup
## database setup

For set up, you'll need to make sure you have mysql installed for Sphinx (search functionality) and Postgres installed for the actual database. The database is currently set up to have the user "Alex".

### mysql

For mysql, use `brew install mysql` and follow those instructions.

I also found I needed to link `sudo ln -s /usr/local/mysql/lib/libmysqlclient.18.dylib /usr/lib/libmysqlclient.18.dylib`.

### postgres

Heroku [manages our database.yml](https://devcenter.heroku.com/articles/heroku-postgresql#connecting-in-ruby) in production (and staging), so all these instructions are just for local environment.

For Postgres, use [postgresapp](http://postgresapp.com/). Use `createuser "Alex" -s` in the shell to create the user. If permissions seem wrong, run `psql` and enter `ALTER ROLE "ALEX" CREATEDB;` to give it the right permissions.

Now you should be able to run `rake db:setup`. Make sure to redo this command and for subsequent commands rerun for `RAILS_ENV=test`, then you can run `bundle` to install gems, and `rspec` to run tests.

Some seed data is necessary for the site to work. It is all handled via `rake db:seed` which is included during `rake db:setup`. The process in general is a backup and dump of the [prod database](https://devcenter.heroku.com/articles/heroku-postgres-import-export#export) is made, then a [seed_dump](https://github.com/rroblak/seed_dump) from it.

For your ease, `rake db:seed` will also create a user and an admin. Both will have the password "password". The usernames should output to console.

# run environments

Staging and production both deploy and depend on [Heroku](https://heroku.com/). You should grab their [cli](https://devcenter.heroku.com/articles/using-the-cli). These instructions assume you've set it up.

Environment variables are kept in an untracked file (`config/application.yml`) managed by [Figaro](https://github.com/laserlemon/figaro#heroku). Running `heroku config --app transbucket` will give you the production env, and `heroku config --app transbucket-staging` staging's env. When you want to push local changes to Heroku (be VERY careful with this), you use `figaro heroku:set -e production`.

## [development (local)](http://localhost:3000)

To run locally, I use `rails s -p 3003` (because I am often running servers on other ports). Then navigate to [localhost:3003](http://localhost:3000/) to browse. You can also just run it without specifiying the port.

If you need to test against an actual S3 instance, you can uncomment the config block in `config/environments/development.rb` and set the required environment varialbles. (You can grab those with `heroku config --app transbucket-staging`. Otherwise you'll just store on your local file system.

## [ci](https://circleci.com/dashboard)

Currently using [CircleCI](https://circleci.com/), which runs the app on [Ubuntu 12](https://circleci.com/docs/build-image-precise/). If you need to change a setting, try changing it via the UI first, then edit the `circle.yml` file.

For master branch: [![CircleCI](https://circleci.com/gh/mooreniemi/Transbucket_Rails/tree/master.svg?style=svg&circle-token=22981fbc246ebdb12d14ef593592e163d093caf7)](https://circleci.com/gh/mooreniemi/Transbucket_Rails/tree/master)

## [staging](https://dashboard-preview.heroku.com/apps/transbucket-staging)

Staging is meant to run in the production environment, as close to actual production as possible. Every successful build on CI (based on every `git push` you do) will trigger a deployment on staging automatically.

If you need to deploying a branch to [staging](https://transbucket-staging.herokuapp.com/) manually:

`git push staging your_branch:master`

Connecting to staging to debug or run tasks:

`heroku run rails console --app transbucket-staging`

## [production](transbucket.com)

For staging and production, assets need to be recompiled. It's wise to clean them first:

```
  rake assets:clean
  RAILS_ENV=production bundle exec rake assets:precompile
```

While we remain on Heroku, it will infer this step for us. (You won't need to do it.)

## tests

`rspec`

Spring is installed to speed up Rails loading times; you should see much shorter load times after the first run.

If you need to see some performance stats, use `rspec --profile`.

### parallel tests

To set up (one time only):

```sh
rake parallel:setup
```

Then, run tests with:

`rake parallel:spec`

Or, to run with Spring for faster load times:

```sh
export DISABLE_SPRING=0 # needed to force activate spring
spring rake parallel:spec
```

### performance testing

Best if you run `unicorn` rather than usual development server `thin`:

`unicorn -c config/unicorn.rb` # this will spawn 3 processes

Then after installing [apache_bench](http://work.stevegrossi.com/2015/02/07/load-testing-rails-apps-with-apache-bench-siege-and-jmeter/) (you should be able to do `brew install ab`) run:

`ab -n 100 -c 10 http://0.0.0.0:8080/`

## static analysis

[rubocop](https://github.com/bbatsov/rubocop) and [brakeman](https://github.com/presidentbeef/brakeman) are available.

## profiling

In dev mode, [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler), [stackprof](https://github.com/tmm1/stackprof) and [ruby-prof](https://github.com/ruby-prof/ruby-prof) are available.

### ruby-prof example

```ruby
  require 'ruby-prof'
  RubyProf.start

  # some ruby code you want to profile

  result = RubyProf.stop
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(STDOUT)

  # if you need the call stack, try
  #printer = RubyProf::CallStackPrinter.new(result)
  #printer.print(File.open('tmp/ruby_prof.html', "w"))
```

### stackprof example

```ruby
  # i add this to the top of a test file
  # say, spec/presenters/pin_presenter_spec.rb

  RSpec.configure do |config|
    config.around(:each) do |example|
      path = Rails.root.join("tmp/stackprof-cpu-test-#{example.full_description.parameterize}.dump")
      StackProf.run(mode: :cpu, out: path.to_s) do
        example.run
      end
    end
  end
```

Then you can use something like: `bundle exec stackprof tmp/stackprof-cpu-test-pinpresenter-filtering-results-returns-pins-scoped-by-procedure.dump` to view the dump.

If you need to find a corresponding call, you can use `git grep suspicious_call -- '*.rb'`.

# caching

Fragment, page, and low-level caching are being used despite Heroku's [ephemeral file store](https://devcenter.heroku.com/articles/dynos#ephemeral-filesystem). Given the site runs on one dyno, and that deploys are infrequent, filestore caching still has some benefit.

Page caching is only used for public areas of the site. For the majority of the site, fragment caching and low-level calls of the form `Rails.cache.fetch` are being used.

# search

We're using [thinking-sphinx](http://freelancing-gods.com/thinking-sphinx/quickstart.html) for our search functionality, with [flying-sphinx](http://info.flying-sphinx.com/) on Heroku.

Though `bundle install` succeeded, I found I needed to use `ln -s /usr/local/lib/libpq.5.8.dylib /usr/local/lib/libpq.5.5.dylib` later to get the `searchd` to run. Run using: `rake ts:regenerate`.

If you're not seeing expected results, use `rake ts:index` to reindex the pins.

# running scheduled jobs / async execution

Via Heroku add-ons we have [scheduler](https://devcenter.heroku.com/articles/scheduler). The process is basically add a `rake` task, and use `heroku addons:open scheduler` to open the scheduler.

The other option is [delayed_job](https://github.com/collectiveidea/delayed_job). During deploy, a separate dyno is used to run `rake jobs:work` which starts the `delayed_job` process that manages execution of the queue.

I've been using the `scheduler` to run things like periodic jobs, whereas I use `delayed_jobs` for stuff like sending an email async. (For an example see `app/helpers/notifications_helper.rb`.)

# more help

- Is there a rake task? Use `rake -T` to check.
- If the search is not functioning, make sure the search daemon is running by using `rake ts:start`.
- Locked yourself out? `User.where(email: 'user_email_address').take.reset_password('new_password','new_password').confirm`
- Having trouble getting to where an error is raised or want a quick feedback loop? Try [pry-rescue](https://github.com/ConradIrwin/pry-rescue) by doing `bundle exec rescue rspec` or `bundle exec rescue rails s`.
- Not seeing a change you expect? Some fragment [caching](http://guides.rubyonrails.org/caching_with_rails.html) is being used. If you need to manually clear it, hop into `rails c` and then run `Rails.cache.clear`. (You can also just `rm -rf tmp`.)

# contact

[email alex](mailto:moore.niemi@gmail.com)
