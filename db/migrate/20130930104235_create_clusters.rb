class CreateClusters < ActiveRecord::Migration
  def change
    create_table :clusters do |t|
      t.belongs_to :solution
      t.timestamps
    end
  end
end
