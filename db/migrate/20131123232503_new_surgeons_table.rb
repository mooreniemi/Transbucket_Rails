class NewSurgeonsTable < ActiveRecord::Migration
  def change
    create_table :surgeons do |t|
      t.integer :id
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :city
      t.string :state
      t.integer :zip
      t.string :country
      t.integer :phone
      t.string :email
      t.string :url
      t.string :procedures

      t.timestamps
    end
  end
end