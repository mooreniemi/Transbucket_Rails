class AddFunctionalIndexesForUserLogin < ActiveRecord::Migration
  disable_ddl_transaction!

  # Devise's find_first_by_auth_conditions (see User.find_first_by_auth_conditions)
  # looks up every login attempt with `lower(username) = ? OR lower(email) = ?`.
  # Postgres can't use the plain btree indexes on username/email to satisfy a
  # lower(...) predicate, so every login was doing a sequential scan over the
  # full users table. CONCURRENTLY avoids locking the table against writes
  # (signups/logins) while these build; disable_ddl_transaction! is required
  # for CONCURRENTLY since it can't run inside a transaction block.
  def up
    execute <<-SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_users_on_lower_username ON users (lower(username));
    SQL
    execute <<-SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_users_on_lower_email ON users (lower(email));
    SQL
  end

  def down
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_users_on_lower_username;"
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_users_on_lower_email;"
  end
end
