class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.belongs_to :surgeon
      t.belongs_to :procedure
      t.timestamps
    end
  end
end
