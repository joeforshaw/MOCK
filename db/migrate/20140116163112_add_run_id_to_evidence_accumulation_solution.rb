class AddRunIdToEvidenceAccumulationSolution < ActiveRecord::Migration
  def change
    add_column :evidence_accumulation_solutions, :run_id, :integer
  end
end
