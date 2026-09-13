class CreateSkills < ActiveRecord::Migration[4.2]
  def change
    create_table :skills do |t|
      t.belongs_to :surgeon
      t.belongs_to :procedure
      t.timestamps
    end
  end
end
