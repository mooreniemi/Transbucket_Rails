class ChangeTypetoBodyType < ActiveRecord::Migration[4.2]
  def change
    rename_column :procedures, :type, :body_type
  end
end
