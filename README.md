Transbucket_Rails
=================

Extensive re-write of the original PHP app with way more organization, validation, and security.

To run locally, I use rails s -p 3003 (because I am often running servers on other ports). Then navigate to localhost:3003 to browse.

The local admin account is username 'zoon' and password 'zoon'. For a non-admin account, simply register your own account.

Helpful commands (from project root):

- If the search is not functioning, make sure the search daemon is running by using "rake ts:start".
- Make sure you are fully migrated by using "rake db:migrate", and when testing use "rake db:test:prepare".
- While this is still a Rails 3 app, I've put the pluck_all function from Rails 4 in the initializers.

Contact me at moore.niemi@gmail.com