class AddCategoryToDiscussions < ActiveRecord::Migration[4.2]
  def up
    add_column :discussions, :category, :string, null: false, default: 'discussion'
    add_index :discussions, [:category, :created_at]
  end

  def down
    remove_index :discussions, [:category, :created_at]
    remove_column :discussions, :category
  end
end
