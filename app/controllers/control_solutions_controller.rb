class ControlSolutionsController < ApplicationController

  def index
    run = Run.find(params[:id])
    respond_to do |format|
      format.html do

      end
      format.csv do
        render text: run.control_solution_csv
      end
    end
  end

end
