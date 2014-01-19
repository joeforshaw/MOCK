class CreateAgglomNodes < ActiveRecord::Migration
  def self.up
    create_table :agglom_nodes do |t|
      t.string  :name
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth
      t.float   :distance
    end
  end

  def self.down
    drop_table :categories
  end

end
