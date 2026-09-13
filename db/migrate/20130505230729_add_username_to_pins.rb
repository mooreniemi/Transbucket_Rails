class AddUsernameToPins < ActiveRecord::Migration[4.2]
	def change
  		add_column :pins, :username, :string
	end
end
