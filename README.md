```
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
   :         ⚧️         :
    :                 :
    :                 :
     :               :
     :               :
      :             :
jrei  :_           _:
        '''-----'''
```


Transbucket.com (Transbucket_Rails)
===================================

The TL;DR of technical specs is: Rails 4.2.8 (in Ruby 2.6.6), using
[bower_rails](https://github.com/rharriso/bower-rails) to manage
Javascript dependencies, on Postgres database for storage, and with
Elasticsearch for search.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [setup](#setup)
  - [docker-compose](#docker-compose)
  - [database setup](#database-setup)
    - [elasticsearch](#elasticsearch)
    - [postgres](#postgres)
- [run environments](#run-environments)
  - [development (local)](#development-local)
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

## docker-compose

Once you have [docker-compose](https://docs.docker.com/compose/install/)
installed, you can spin up a containerized local dev environment by running:

```sh
docker-compose up --build
```

This will bring up the app at http://localhost:3000 alongside Elasticsearch,
Kibana, and Postgres. You can then complete the initial setup by running:

```sh
docker-compose exec web bundle exec rake db:setup
docker-compose exec web \
    bundle exec rake environment elasticsearch:import:model CLASS=Pin INDEX=development_pins FORCE=y
```

When running the services directly on the host with
`docker-compose.override.yml`, Docker exposes Postgres on host port `5433`
(the container still listens on `5432`). Use `POSTGRES_PORT=5433` for local
Rails commands and tests, together with the `postgres` / `password` connection
settings shown in the smoke commands below.

For the supported host-Rails workflow, start only the backing services and use
the wrapper for tests:

```sh
docker-compose up -d db elasticsearch
script/local_rspec spec/controllers/procedures_controller_spec.rb
```

This uses the local `psql_test` database. Full Compose mode remains available
when Rails itself needs to run in the `web` container; do not combine its
internal `db:5432` settings with a host Rails process.

Before pushing any branch to CircleCI, verify the same change locally first:

```sh
rbenv exec bundle install
script/local_setup
script/local_rspec spec/controllers/procedures_controller_spec.rb spec/controllers/surgeons_controller_spec.rb
script/local_rspec
```

Do not use a CircleCI run as the first test of a Rails or dependency change.
The local database and focused specs must pass before starting the full local
suite; only then should the branch be pushed to CircleCI for an independent
environment check. Capybara uses an OS-assigned local test port, so do not
reintroduce a fixed browser-test port.

To stop the environment, run:
```sh
docker-compose down
```

Alternatively, you can set up all the services directly on your machine as
described in the rest of this section.

## database setup

For set up, you'll need to make sure you have Elasticsearch installed for search functionality and Postgres installed for the actual database. The database is currently set up to have the user "Alex".

### elasticsearch

```
brew install elasticsearch
brew install kibana

# to make sure ES is up
curl localhost:9200
```

Then you can access the [Kibana UI](http://localhost:5601/app/kibana#/dev_tools/console).

### postgres

Heroku [manages our database.yml](https://devcenter.heroku.com/articles/heroku-postgresql#connecting-in-ruby) in production (and staging), so all these instructions are just for local environment.

For Postgres on Mac, you can use [postgresapp](http://postgresapp.com/).
On Linux check your distribution details.

Use `createuser "Alex" -s` in the shell to create the user. (On
Linux,`createuser` is its own executable, so log onto `psql` first.) If
permissions seem wrong, run `psql` and enter `ALTER ROLE "ALEX" CREATEDB;`
to give it the right permissions.

Now you should be able to run `rake db:setup`. Make sure to redo this command and for subsequent commands rerun for `RAILS_ENV=test`, then you can run `bundle` to install gems, and `rspec` to run tests.

Some seed data is necessary for the site to work. It is all handled via `rake db:seed` which is included during `rake db:setup`. The process in general is a backup and dump of the [prod database](https://devcenter.heroku.com/articles/heroku-postgres-import-export#export) is made, then a [seed_dump](https://github.com/rroblak/seed_dump) from it.

For your ease, `rake db:seed` will also create a user and an admin. Both will have the password "password". The usernames should output to console.

On Ubuntu, you will likely need to follow [these
instructions](https://gist.github.com/p1nox/4953113) after you've
installed headers.

# run environments

Staging and production both deploy and depend on [Heroku](https://heroku.com/). You should grab their [cli](https://devcenter.heroku.com/articles/using-the-cli). These instructions assume you've set it up.

Environment variables are kept in an untracked file (`config/application.yml`) managed by [Figaro](https://github.com/laserlemon/figaro#heroku). Running `heroku config --app transbucket` will give you the production env, and `heroku config --app transbucket-staging` staging's env. When you want to push local changes to Heroku (be VERY careful with this), you use `figaro heroku:set -e production`.

## [development (local)](http://127.0.0.1:3003)

Use the Docker-backed host-Rails workflow:

```
script/local_setup
script/local_server
```

`local_setup` starts only Docker Postgres and Elasticsearch, runs the local
development database setup, and resets the confirmed `meowmeow` account.
`local_server` runs Rails on `http://127.0.0.1:3003` with Postgres on host
port `5433`. Do not use the default `rails server` command for this workflow:
it falls back to Postgres port `5432` and the local `Alex` role.

Use `meowmeow` / `local-login` in the browser. `local_reset_user` can be run
again at any time and changes only the local Docker development database.

If you need to test against an actual S3 instance, you can uncomment the config block in `config/environments/development.rb` and set the required environment varialbles. (You can grab those with `heroku config --app transbucket-staging`. Otherwise you'll just store on your local file system.

## [ci](https://circleci.com/dashboard)

Currently using [CircleCI](https://circleci.com/) (config version 2.1, `.circleci/config.yml`), running `cimg/ruby:3.1.6` images with the `browser-tools` orb for the Selenium/Capybara feature specs. It runs `build` then `test` on a push to any branch -- there's no branch filter restricting it to PRs specifically, and no deploy job of any kind. CI is test-only; it has no effect on staging or production.

For master branch: [![CircleCI](https://circleci.com/gh/mooreniemi/Transbucket_Rails/tree/master.svg?style=svg&circle-token=22981fbc246ebdb12d14ef593592e163d093caf7)](https://circleci.com/gh/mooreniemi/Transbucket_Rails/tree/master)

## [staging](https://dashboard-preview.heroku.com/apps/transbucket-staging)

### Product release notes

Every user-facing feature must include a corresponding entry in the in-app
newsfeed (`PagesController::NEWSFEED_ENTRY_TIMESTAMPS` and the `newsfeed`
translations). This makes shipped improvements discoverable after release.
Do not create newsfeed entries for admin-only tools, authorization/security
repairs, maintenance, or other internal changes.

Staging is meant to run in the production environment, as close to actual production as possible. Deploys to staging are always manual -- nothing in CI deploys it automatically.

To deploy a branch to [staging](https://transbucket-staging.herokuapp.com/):

`git push staging your_branch:master`

The locale-aware staging smoke test exercises legacy redirects, localized
metadata and newsfeed output, then logs in and verifies multi-image pin
creation, editing, and search indexing. Supply credentials through the shell;
never commit or paste them into the repository or chat:

```
STAGING_USER=meowmeow STAGING_PASSWORD='...' \
  bundle exec ruby script/staging_smoke.rb
```

Use `STAGING_LOCALES=en,de` (or another comma-separated set of supported
locales) to run the authenticated submission flow through each locale. The
script writes one test pin per locale to staging and
requires a worker dyno for the search-indexing assertion; scale that worker
back to zero afterward if it is not otherwise needed.

Connecting to staging to debug or run tasks:

`heroku run rails console --app transbucket-staging`

## [production](transbucket.com)

Production deploy is manual, and separate from CI/CD -- passing CircleCI tests does not deploy anything. The Heroku production deploy target is `main`; deploy master with:

`git push production master:main`

(The `production` remote points at Heroku's `transbucket` app git URL.) There is currently no automated or gated path from a green CircleCI build to a production deploy.

Before deploying, confirm the exact commit and Heroku ref:

```
git fetch production main
git rev-parse master origin/master production/main
```

`master` and `origin/master` should be the tested commit. A normal deploy is a
fast-forward push. If Heroku rejects the push because `production/main` is
stale or divergent, stop and inspect the two histories before changing the
remote ref; do not use an unconditional force push. The one-time
`--force-with-lease` reconciliation used in September 2026 is not part of the
normal deploy path.

### Pre-production release gate

Before every production deploy, run the relevant local suite and deploy the exact tested commit to staging. After the staging release completes, run the authenticated smoke with credentials supplied only in the local shell:

```
STAGING_USER=meowmeow STAGING_PASSWORD='(local secret)' \
  STAGING_URL=https://transbucket-staging.herokuapp.com \
  bundle exec ruby script/staging_smoke.rb
```

The smoke must report `staging smoke ok`; it verifies a real GET-to-POST login with CSRF protection, pin creation with two images, editing, and search. If search indexing is enabled asynchronously on staging, temporarily scale the staging worker for the smoke and scale it back to zero afterward. Never put staging credentials in CI, the repository, or logged deploy commands.

Only after that gate passes may the production cookie-domain configuration be set and the tested commit be pushed to the production `main` ref:

```
heroku config:set SESSION_COOKIE_DOMAIN=.transbucket.com --app transbucket
git push production master:main
```

After deployment, verify fresh GET-to-POST login flows on both `https://transbucket.com` and `https://www.transbucket.com`. The latter should redirect GET/HEAD requests to the apex host. If verification fails, deploy the previous known-good production commit and restore the prior production configuration.

### Authentication monitoring follow-up

This repository does not contain New Relic alert definitions. An alert for `ActionController::InvalidAuthenticityToken` and elevated `422` responses on `POST /users/sign_in` is an optional external follow-up only if it is already included at no additional cost in the current plan. Do not add paid monitoring; the required safeguards are the repository tests and authenticated staging smoke gate.

For staging and production, assets need to be recompiled. It's wise to clean them first:

```
  rake assets:clean
  RAILS_ENV=production bundle exec rake assets:precompile
```

While we remain on Heroku, it will infer this step for us. (You won't need to do it.)

## tests

On the Ruby side, `rspec`, but you also need `chromium-chromedriver` in
order to run UI integ tests, via Selenium. For example, on Ubuntu you can
run: `sudo apt-get install chromium-chromedriver`. If you want to spy on
what's happening during a Selenium run, you can edit
`spec/support/capybara_config.rb` to switch off `_headless`.

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

The `Pin` model has a callback that will update Elasticsearch. But when
you are initially filling the index, you want to run the below command
after you have seeded the database. Essentially Elasticsearch is
a secondary view of our database data. It is safe to delete it and reindex
it.

For staging validation we intentionally reuse the production Bonsai cluster
and isolate by index prefix. That lets us recreate `staging_pins` freely
without putting the database at risk. We do not share the database itself.

After changing the indexed Pin representation, rebuild only staging with:

```
heroku run rake environment elasticsearch:import:model CLASS='Pin' INCLUDE='PinImage,Surgeon,Procedure' FORCE=true -a transbucket-staging
```

This uses staging's `INDEX_PREFIX=staging` and recreates only `staging_pins`.
Never run this command against the production app as part of staging testing.

For a fast local smoke loop, reseed the test DB and run the same script
against localhost:

```
DISABLE_SPRING=1 OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES \
POSTGRES_HOST=localhost POSTGRES_PORT=5433 POSTGRES_USER=postgres \
POSTGRES_PASSWORD=password RAILS_ENV=test bundle exec rake db:seed

DISABLE_SPRING=1 OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES \
POSTGRES_HOST=localhost POSTGRES_PORT=5433 POSTGRES_USER=postgres \
POSTGRES_PASSWORD=password RAILS_ENV=test bundle exec rake jobs:work

STAGING_URL=http://127.0.0.1:3003 \
STAGING_USER=meowmeow STAGING_PASSWORD='local-login' \
bundle exec ruby script/staging_smoke.rb
```

```
rake environment elasticsearch:import:model CLASS='Pin' INCLUDE='PinImage,Surgeon,Procedure' FORCE=true

# should show you the index you created, labeled by env
curl localhost:9200/_cat/indices
```

# running scheduled jobs / async execution

Via Heroku add-ons we have [scheduler](https://devcenter.heroku.com/articles/scheduler). The process is basically add a `rake` task, and use `heroku addons:open scheduler` to open the scheduler.

The other option is [delayed_job](https://github.com/collectiveidea/delayed_job). During deploy, a separate dyno is used to run `rake jobs:work` which starts the `delayed_job` process that manages execution of the queue.

I've been using the `scheduler` to run things like periodic jobs, whereas I use `delayed_jobs` for stuff like sending an email async. (For an example see `app/helpers/notifications_helper.rb`.)

# more help

- Is there a rake task? Use `rake -T` to check.
- Locked yourself out? `User.where(email: 'user_email_address').take.reset_password('new_password','new_password').confirm`
- Having trouble getting to where an error is raised or want a quick feedback loop? Try [pry-rescue](https://github.com/ConradIrwin/pry-rescue) by doing `bundle exec rescue rspec` or `bundle exec rescue rails s`.
- Not seeing a change you expect? Some fragment [caching](http://guides.rubyonrails.org/caching_with_rails.html) is being used. If you need to manually clear it, hop into `rails c` and then run `Rails.cache.clear`. (You can also just `rm -rf tmp`.)

# contact

[email alex](mailto:webmaster@transbucket.com)
