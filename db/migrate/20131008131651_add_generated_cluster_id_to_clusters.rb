class AddGeneratedClusterIdToClusters < ActiveRecord::Migration
  def change
    add_column :clusters, :generated_cluster_id, :integer
  end
end
