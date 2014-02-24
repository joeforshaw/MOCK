class CreateMdsSolutions < ActiveRecord::Migration
  def change
    create_table :mds_solutions do |t|
      t.references :solution
      t.timestamps
    end
  end
end
