class MdsSolutionsController < ApplicationController

  def show
    @solution = Solution.find(params[:id])
    @mds_solution = @solution.mds_solution

    if @mds_solution.nil?
      @mds_solution = MdsSolution.create(:solution => @solution)
      @mds_solution.calculate
    end

    respond_to do |format|
      format.html do
        redirect_to @mds_solution.solution
      end
      format.csv do
        render text: @mds_solution.to_csv
      end
    end
  end

end
