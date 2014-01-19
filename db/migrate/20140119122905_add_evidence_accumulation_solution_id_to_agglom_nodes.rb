class AddEvidenceAccumulationSolutionIdToAgglomNodes < ActiveRecord::Migration
  def change
    add_column :agglom_nodes, :evidence_accumulation_solution_id, :integer
  end
end
