class AddDatasetIdIndexToDatapoints < ActiveRecord::Migration
  def change
    add_index :datapoints, :dataset_id
  end
end
