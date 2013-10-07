class AddConnectivityAndDeviationToSolutions < ActiveRecord::Migration
  def change
    add_column :solutions, :connectivity, :float
    add_column :solutions, :deviation, :float
  end
end
