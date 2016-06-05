Transbucket.com (Transbucket_Rails)
===================================

Rails 4.1.2 (in Ruby 2.2.2), using [bower_rails](https://github.com/rharriso/bower-rails) to manage javascript dependencies.

# setup
## database setup

For set up, you'll need to make sure you have mysql installed for Sphinx (search functionality) and Postgres installed for the actual database. The database is currently set up to have the user "Alex".

### mysql

For mysql, use `brew install mysql` and follow those instructions.

I also found I needed to link `sudo ln -s /usr/local/mysql/lib/libmysqlclient.18.dylib /usr/lib/libmysqlclient.18.dylib`.

### postgres

For Postgres, use [postgresapp](http://postgresapp.com/). Use `createuser "Alex" -s` in the shell to create the user. If permissions seem wrong, run `psql` and enter `ALTER ROLE "ALEX" CREATEDB;` to give it the right permissions.

Now you should be able to run `rake db:create` and `rake db:migrate`. Make sure to rerun migrations for `RAILS_ENV=test`, then you can run `bundle` to install gems, and `rspec` to run tests.

Some seed data is necessary for the site to work. Run `rake genders:create`, `rake surgeons:seed`, and `rake procedure:create`.

For your ease, use `rake test_users:create` to create a user and an admin. Both will have the password "password". The usernames should output to console.

# run environments

Staging and production both deploy and depend on [heroku](https://heroku.com/). You should grab their [cli](https://devcenter.heroku.com/articles/using-the-cli). These instructions assume you've set it up.

## [local](http://localhost:3000)

To run locally, I use `rails s -p 3003` (because I am often running servers on other ports). Then navigate to [localhost:3003](http://localhost:3000/) to browse. You can also just run it without specifiying the port.

## [ci](https://circleci.com/dashboard)

Currently trying out [CircleCI](https://circleci.com/), which runs the app on [Ubuntu 12](https://circleci.com/docs/build-image-precise/).

For fix_presenter branch: [![CircleCI](https://circleci.com/gh/mooreniemi/Transbucket_Rails/tree/fix_presenter.svg?style=svg&circle-token=22981fbc246ebdb12d14ef593592e163d093caf7)](https://circleci.com/gh/mooreniemi/Transbucket_Rails/tree/fix_presenter)

For master branch: [![CircleCI](https://circleci.com/gh/mooreniemi/Transbucket_Rails/tree/master.svg?style=svg&circle-token=22981fbc246ebdb12d14ef593592e163d093caf7)](https://circleci.com/gh/mooreniemi/Transbucket_Rails/tree/master)

## [staging](https://dashboard-preview.heroku.com/apps/transbucket-staging)

Deploying a branch to [staging](https://transbucket-staging.herokuapp.com/):

`git push staging fix_presenter:master`

Connecting to staging to debug or run tasks:

`heroku run rails console --app transbucket-staging`

## [production](transbucket.com)

## tests

`rspec`


## profiling

In dev mode, [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler) and [ruby-prof](https://github.com/ruby-prof/ruby-prof) are available.

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

If you need to find a corresponding call, you can use `git grep suspicious_call -- '*.rb'`.

# more help

- Is there a rake task? Use `rake -T` to check.
- If the search is not functioning, make sure the search daemon is running by using `rake ts:start`.
- Locked yourself out? `User.where(email: 'user_email_address').take.reset_password('new_password','new_password').confirm`
- Having trouble getting to where an error is raised or want a quick feedback loop? Try [pry-rescue](https://github.com/ConradIrwin/pry-rescue) by doing `bundle exec rescue rspec` or `bundle exec rescue rails s`.
- Not seeing a change you expect? Some fragment [caching](http://guides.rubyonrails.org/caching_with_rails.html) is being used. If you need to manually clear it, hop into `rails c` and then run `Rails.cache.clear`. (You can also just `rm -rf tmp`.)

# contact

[email alex](mailto:moore.niemi@gmail.com)
