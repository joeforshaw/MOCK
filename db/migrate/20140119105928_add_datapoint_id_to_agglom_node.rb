class AddDatapointIdToAgglomNode < ActiveRecord::Migration
  def change
    add_column :agglom_nodes, :datapoint_id, :integer
  end
end
