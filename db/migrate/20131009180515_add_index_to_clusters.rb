class AddIndexToClusters < ActiveRecord::Migration
  def change
    add_index :clusters, :Cluster_id
  end
end
