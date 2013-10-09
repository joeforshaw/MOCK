class SolutionsController < ApplicationController

  def show
    respond_to do |format|
      format.html do
        @solution = Solution.find(params[:id])
        gon.solution_path = "#{solution_path(@solution.id)}.csv"
        gon.solution_front_path = "#{solution_path(@solution.id)}.csv"
      end
      format.csv do
        render text: Solution.find(params[:id]).to_csv
      end
    end
  end

end
