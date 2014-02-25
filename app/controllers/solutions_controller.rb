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
    @solution = Solution.find(params[:id])
    @dataset = @solution.run.dataset

    if !@solution.parsed
      @solution.save_data_file
    end

    respond_to do |format|

      format.html do
        @body_classes << "graph-body"
        gon.solution_path = "#{solution_path(@solution.id)}.csv"
        gon.mds_path = "#{mds_solution_path(@solution.id)}.csv"
        gon.is_plot = true
        gon.is_solution = true
        gon.use_mds = true
        gon.number_of_clusters = @solution.clusters.size
      end

      format.csv do
        render text: @solution.to_csv
      end

    end
  end

end
