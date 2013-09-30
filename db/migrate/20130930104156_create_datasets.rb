class CreateDatasets < ActiveRecord::Migration
  def change
    create_table :datasets do |t|
      t.belongs_to :user
      t.timestamps
    end
  end
end
