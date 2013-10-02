class CreateDatasets < ActiveRecord::Migration
  def change
    create_table :datasets do |t|
      t.string :name
      t.belongs_to :user
      t.timestamps
    end
  end
end
