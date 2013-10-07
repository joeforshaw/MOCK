class SolutionsController < ApplicationController

  def show
    @solution = Solution.find(params[:id])
    gon.solution_path = "#{dataset_path(@solution.run.dataset.id)}.csv"
    gon.solution_front_path = "#{dataset_path(@solution.run.dataset.id)}.csv"
  end

end
