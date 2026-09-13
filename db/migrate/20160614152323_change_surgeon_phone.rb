class ChangeSurgeonPhone < ActiveRecord::Migration[4.2]
  def change
    change_column :surgeons, :phone, :string, :limit => 20
  end
end
