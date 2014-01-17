class AddEvidenceAccumulationToRun < ActiveRecord::Migration
  def change
    add_column :runs, :evidence_accumulation, :boolean
  end
end
