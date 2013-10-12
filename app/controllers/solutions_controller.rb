class SolutionsController < ApplicationController

  def index
    run = Run.find(params[:id])
    respond_to do |format|
      format.html do
      end
      format.csv do
        render text: run.objective_csv
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        @solution = Solution.find(params[:id])
        gon.solution_path = "#{solution_path(@solution.id)}.csv"
      end
      format.csv do
        render text: Solution.find(params[:id]).to_csv
      end
    end
  end

end
