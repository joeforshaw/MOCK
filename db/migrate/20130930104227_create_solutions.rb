class CreateSolutions < ActiveRecord::Migration
  def change
    create_table :solutions do |t|

      t.timestamps
    end
  end
end
