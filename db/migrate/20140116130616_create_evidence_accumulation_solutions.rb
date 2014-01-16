class CreateEvidenceAccumulationSolutions < ActiveRecord::Migration
  def change
    create_table :evidence_accumulation_solutions do |t|

      t.timestamps
    end
  end
end
