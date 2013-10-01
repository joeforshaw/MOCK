class DatasetsController < ApplicationController

  def new
    @dataset = Dataset.new
  end

  def create
    puts params[:dataset][:picture]
  end

  def index
    if user_signed_in?
      @datasets = current_user.datasets
    end
  end

end
