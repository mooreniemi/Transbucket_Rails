class CreatePreferences < ActiveRecord::Migration[4.2]
  def change
    create_table :preferences do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
