Transbucket.com (Transbucket_Rails)
===================================

Rails 4 (in Ruby 2.1.3), using [bower_rails](https://github.com/rharriso/bower-rails) to manage javascript dependencies.


## database setup
# mysql
For set up, you'll need to make sure you have mysql installed for Sphinx (search functionality) and Postgres installed for the actual database. The database is currently set up to have the user "Alex".

For mysql, use `brew install mysql` and follow those instructions.

I also found I needed to link `sudo ln -s /usr/local/mysql/lib/libmysqlclient.18.dylib /usr/lib/libmysqlclient.18.dylib`.

# postgres
For Postgres, use [postgresapp](http://postgresapp.com/). Use `createuser "Alex"` in the shell to create the user, then in psql run `ALTER ROLE "ALEX" CREATEDB;` to give it the right permissions.

Now you should be able to run `rake db:create` and `rake db:migrate`. Make sure to rerun migrations for `RAILS_ENV=test`, then you can run `bundle` to install gems, and `rspec` to run tests.

Some seed data is necessary for the site to work. Run `rake genders:create`, `rake surgeons:seed`, and `rake procedure:create`.

For your ease, use `rake test_users:create` to create a user and an admin. Both will have the password "password". The usernames should output to console.

# running locally

To run locally, I use `rails s -p 3003` (because I am often running servers on other ports). Then navigate to localhost:3003 to browse.


# tests

`rspec`

# more help

Helpful commands (from project root):

- Is there a rake task? Use `rake -T` to check.
- If the search is not functioning, make sure the search daemon is running by using `rake ts:start`.
- Locked yourself out? `User.where(email: 'user_email_address').take.reset_password('new_password','new_password').confirm`

# contact
moore.niemi@gmail.com
