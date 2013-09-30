class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.float :runtime
      t.belongs_to :dataset
      t.belongs_to :user
      t.timestamps
    end
  end
end
