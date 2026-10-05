class CreateDiscussions < ActiveRecord::Migration[4.2]
  def up
    create_table :discussions do |t|
      t.integer :user_id, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.string :visibility, null: false, default: 'everyone'
      t.string :state, null: false, default: 'published'
      t.timestamps null: false
    end

    add_index :discussions, :user_id
    add_index :discussions, [:state, :visibility, :created_at]
  end

  def down
    drop_table :discussions
  end
end
