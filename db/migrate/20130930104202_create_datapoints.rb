class CreateDatapoints < ActiveRecord::Migration
  def change
    create_table :datapoints do |t|
      t.belongs_to :dataset
      t.timestamps
    end
  end
end
