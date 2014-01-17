class AddEvidenceAccumulationSolutionIdToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :evidence_accumulation_solution_id, :integer
  end
end
