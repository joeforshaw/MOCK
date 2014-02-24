class MdsSolutionsController < ApplicationController

  def show
    respond_to do |format|
      format.csv do
        render text: MDSSolution.find(params[:id]).to_csv
      end
    end
  end

end
