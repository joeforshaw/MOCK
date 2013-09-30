class CreateDatavalues < ActiveRecord::Migration
  def change
    create_table :datavalues do |t|
      t.float :value
      t.belongs_to :datapoint
      t.timestamps
    end
  end
end
