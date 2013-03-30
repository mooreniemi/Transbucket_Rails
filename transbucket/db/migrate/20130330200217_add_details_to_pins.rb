class AddDetailsToPins < ActiveRecord::Migration
  def change
  	add_column :pins, :procedure, :string
  	add_column :pins, :revision, :boolean
  	add_column :pins, :surgeon, :string
  	add_column :pins, :details, :text
  	add_column :pins, :cost, :integer
  end
end
