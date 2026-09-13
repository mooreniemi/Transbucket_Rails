class CreatePins < ActiveRecord::Migration[4.2]
  def change
    create_table :pins do |t|
      t.string :description

      t.timestamps
    end
  end
end
