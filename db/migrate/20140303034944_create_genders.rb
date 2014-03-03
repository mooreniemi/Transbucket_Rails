class CreateGenders < ActiveRecord::Migration
  def change
    create_table :genders do |t|
      t.string :name

      t.timestamps
    end
  end
end
