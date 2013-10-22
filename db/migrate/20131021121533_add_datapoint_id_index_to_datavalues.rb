class AddDatapointIdIndexToDatavalues < ActiveRecord::Migration
  def change
    add_index :datavalues, :datapoint_id
  end
end
