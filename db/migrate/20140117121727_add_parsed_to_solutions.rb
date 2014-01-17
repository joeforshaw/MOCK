class AddParsedToSolutions < ActiveRecord::Migration
  def change
    add_column :solutions, :parsed, :boolean
  end
end
