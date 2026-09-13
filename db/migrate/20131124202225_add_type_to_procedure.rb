class AddTypeToProcedure < ActiveRecord::Migration[4.2]
  def change
    add_column :procedures, :type, :string
    add_column :procedures, :gender, :string

    add_column :procedures, :avg_sensation, :integer
    add_column :procedures, :avg_satisfaction, :integer
  end
end
