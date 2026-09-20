class CreateUserTrustGrants < ActiveRecord::Migration
  def up
    create_table :user_trust_grants do |t|
      t.integer :user_id, null: false
      t.integer :granted_by_user_id
      t.string :kind, null: false
      t.string :source, null: false, default: 'automatic'
      t.text :internal_note
      t.datetime :granted_at, null: false
      t.datetime :revoked_at
      t.timestamps null: false
    end

    add_index :user_trust_grants, [:user_id, :kind], unique: true
    add_index :user_trust_grants, :granted_by_user_id

    # Existing published submissions are the same contribution signal as new
    # ones. This is deliberately generic: privileged grants are made through
    # the admin UI or a one-off production operation, never by naming a person
    # in source control.
    execute <<-SQL.squish
      INSERT INTO user_trust_grants
        (user_id, kind, source, granted_at, created_at, updated_at)
      SELECT DISTINCT user_id, 'contributor', 'automatic', NOW(), NOW(), NOW()
      FROM pins
      WHERE state = 'published' AND user_id IS NOT NULL
      ON CONFLICT (user_id, kind) DO NOTHING
    SQL
  end

  def down
    drop_table :user_trust_grants
  end
end
