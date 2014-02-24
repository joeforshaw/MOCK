class AddClusterableToDatapoints < ActiveRecord::Migration
  def change
    add_column :datapoints, :clusterable_id, :integer
    add_column :datapoints, :clusterable_type, :string
  end
end
