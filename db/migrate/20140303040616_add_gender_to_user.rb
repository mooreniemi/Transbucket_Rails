class AddGenderToUser < ActiveRecord::Migration[4.2]
  def change
  	rename_column :users, :gender, :gender_id
  end
end
