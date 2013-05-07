class AddUsernameToPins < ActiveRecord::Migration
	def change
  		add_column :pins, :username, :string
	end
end