class AddCompletedToEvidenceAccumulationSolutions < ActiveRecord::Migration
  def change
    add_column :evidence_accumulation_solutions, :completed, :boolean
  end
end
