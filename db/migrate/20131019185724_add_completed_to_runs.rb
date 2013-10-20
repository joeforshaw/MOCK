class AddCompletedToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :completed, :boolean
  end
end
