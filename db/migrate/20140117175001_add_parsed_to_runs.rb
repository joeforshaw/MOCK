class AddParsedToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :parsed, :boolean
  end
end
