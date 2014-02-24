class RemoveSolutionIdFromCluster < ActiveRecord::Migration
  def change
    remove_column :clusters, :solution_id, :integer
  end
end
