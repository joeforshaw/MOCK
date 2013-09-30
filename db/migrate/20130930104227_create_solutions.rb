class CreateSolutions < ActiveRecord::Migration
  def change
    create_table :solutions do |t|
      t.belongs_to :run
      t.timestamps
    end
  end
end
