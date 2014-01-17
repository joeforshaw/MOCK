class SolutionsController < ApplicationController

  before_filter :authenticate_user!

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
    @body_classes << "graph-body"
    @solution = Solution.find(params[:id])
    @dataset = @solution.run.dataset

    gon.solution_path = "#{solution_path(@solution.id)}.csv"
    gon.is_solution = true;

    if !@solution.parsed
      @solution.save_data_file
    end

    respond_to do |format|
      format.html do          
      end
      format.csv do
        render text: @solution.to_csv
      end
    end
  end

end
