class CreateGenders < ActiveRecord::Migration[4.2]
  def change
    create_table :genders do |t|
      t.string :name

      t.timestamps
    end
  end
end
