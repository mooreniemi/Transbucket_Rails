class MakeGenderIntegerAndDefaultOne < ActiveRecord::Migration
  def up
    change_column :users, :gender_id, 'integer USING CAST(gender_id AS integer)', default: 4, null: false
  end

  def down
    change_column :users, :gender_id, :string
  end
end
