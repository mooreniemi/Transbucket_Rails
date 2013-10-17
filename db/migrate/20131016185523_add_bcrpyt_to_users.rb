class AddBcrpytToUsers < ActiveRecord::Migration
  def change
    add_column :users, :md5, :string
  end
end
