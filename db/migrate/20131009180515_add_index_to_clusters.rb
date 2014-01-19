class AddIndexToClusters < ActiveRecord::Migration
  def change
    add_index :clusters, :cluster_id
  end
end
