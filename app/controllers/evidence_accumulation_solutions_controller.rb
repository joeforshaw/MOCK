class EvidenceAccumulationSolutionsController < ApplicationController

  def show
    @evidence_accumulation_solution = EvidenceAccumulationSolution.find(params[:id])
    respond_to do |format|
      format.html do
        gon.evidence_accumulation_solution_path = @evidence_accumulation_solution.newick_format_path
      end
      format.newick do
        render text: Newick.format(@evidence_accumulation_solution.agglom_node)
      end
    end
  end

end
