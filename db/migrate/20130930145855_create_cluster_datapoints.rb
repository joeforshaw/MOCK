class CreateClusterDatapoints < ActiveRecord::Migration
  def change
    create_table :cluster_datapoints do |t|
      t.belongs_to :cluster
      t.belongs_to :datapoint
      t.timestamps
    end
  end
end
