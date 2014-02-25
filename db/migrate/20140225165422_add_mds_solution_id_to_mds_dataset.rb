class AddMdsSolutionIdToMdsDataset < ActiveRecord::Migration
  def change
    add_column :mds_datasets, :mds_solution_id, :integer
  end
end
