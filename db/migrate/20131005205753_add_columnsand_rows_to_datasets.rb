class AddColumnsandRowsToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :columns, :integer
    add_column :datasets, :rows, :integer
  end
end
