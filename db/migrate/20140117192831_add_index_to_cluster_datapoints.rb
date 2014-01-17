class AddIndexToClusterDatapoints < ActiveRecord::Migration
  def change
    add_index :cluster_datapoints, :cluster_id
  end
end
