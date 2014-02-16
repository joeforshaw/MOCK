class EvidenceAccumulationSolutionsController < ApplicationController

  def show
    @evidence_accumulation_solution = EvidenceAccumulationSolution.find(params[:id])
    gon.is_dendrogram = true
    respond_to do |format|
      format.html do
        @run = @evidence_accumulation_solution.run
        if params.has_key?(:solution)
          @solution = Solution.find(params[:solution])
          gon.solution_path = "#{solution_path(@solution.id)}.csv"
        end
        gon.evidence_accumulation_solution_path = @evidence_accumulation_solution.newick_format_path
        gon.evidence_accumulation_path = evidence_accumulation_solution_path(@run.id)
      end
      format.newick do
        render text: Newick.format(@evidence_accumulation_solution.agglom_node)
      end
    end
  end

end
