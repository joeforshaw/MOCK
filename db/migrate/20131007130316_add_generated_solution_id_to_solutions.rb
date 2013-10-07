class AddGeneratedSolutionIdToSolutions < ActiveRecord::Migration
  def change
    add_column :solutions, :generated_solution_id, :integer
  end
end
