class CreateMdsDatasets < ActiveRecord::Migration
  def change
    create_table :mds_datasets do |t|

      t.timestamps
    end
  end
end
