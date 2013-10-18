class AddStateToComments < ActiveRecord::Migration
  def change
    add_column :comments, :state, :string
  end
end
