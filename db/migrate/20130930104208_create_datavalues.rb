class CreateDatavalues < ActiveRecord::Migration
  def change
    create_table :datavalues do |t|

      t.timestamps
    end
  end
end
