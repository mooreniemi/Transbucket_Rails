class ChangeSurgeonIdOnPin < ActiveRecord::Migration
  def up
  	change_column :pins, :surgeon_id, :integer
  end

  def down
  	change_column :pins, :surgeon_id, :string
  end
end
