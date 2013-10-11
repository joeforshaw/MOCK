class CreateControlSolutions < ActiveRecord::Migration
  def change
    create_table :control_solutions do |t|
      t.belongs_to :run
      t.float :connectivity
      t.float :deviation
      t.timestamps
    end
  end
end
