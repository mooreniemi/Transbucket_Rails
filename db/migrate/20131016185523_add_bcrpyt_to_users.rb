class AddBcrpytToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :md5, :string
  end
end
