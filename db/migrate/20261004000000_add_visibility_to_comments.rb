class AddVisibilityToComments < ActiveRecord::Migration[4.2]
  def up
    add_column :comments, :visibility, :string, null: false, default: 'everyone'
    add_index :comments, [:commentable_type, :commentable_id, :parent_id, :visibility],
      name: 'index_comments_on_subject_visibility'
    add_index :user_trust_grants, [:user_id, :revoked_at, :kind],
      name: 'index_user_trust_grants_on_active_kind'
  end

  def down
    remove_index :user_trust_grants, name: 'index_user_trust_grants_on_active_kind'
    remove_index :comments, name: 'index_comments_on_subject_visibility'
    remove_column :comments, :visibility
  end
end
