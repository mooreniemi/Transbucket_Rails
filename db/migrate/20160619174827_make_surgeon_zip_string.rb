class MakeSurgeonZipString < ActiveRecord::Migration[4.2]
  def up
    change_column :surgeons, :zip, :string
  end

  def down
    change_column :surgeons, :zip, 'integer USING CAST(zip AS integer)'
  end
end
