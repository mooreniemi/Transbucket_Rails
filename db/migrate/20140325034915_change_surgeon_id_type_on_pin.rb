class ChangeSurgeonIdTypeOnPin < ActiveRecord::Migration[4.2]
  def up
  	change_column :pins, :surgeon_id, 'integer USING CAST(surgeon_id AS integer)'
  end

  def down
  	change_column :pins, :surgeon_id, :string
  end
end
