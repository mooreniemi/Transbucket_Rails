class AddStateToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :state, :string
  end
end
