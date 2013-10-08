class AddSequenceIdToDatapoints < ActiveRecord::Migration
  def change
    add_column :datapoints, :sequence_id, :integer
  end
end
