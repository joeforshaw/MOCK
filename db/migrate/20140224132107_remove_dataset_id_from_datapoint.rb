class RemoveDatasetIdFromDatapoint < ActiveRecord::Migration
  def change
    remove_column :datapoints, :dataset_id, :integer
  end
end
