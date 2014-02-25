class AddMeasurementsToSolutions < ActiveRecord::Migration
  def change
    add_column :solutions, :silhouette_width, :float
    add_column :solutions, :control_distance, :float
  end
end
