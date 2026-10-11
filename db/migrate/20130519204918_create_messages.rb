class CreateMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :messages do |t|

      t.timestamps
    end
  end
end
