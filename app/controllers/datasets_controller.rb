class DatasetsController < ApplicationController

  def new
    if user_signed_in?
      @dataset = Dataset.new
    else
      redirect_to :new_user_session
    end
  end

  def create
    if user_signed_in?
      uploaded_io = params[:dataset][:file]
      Dataset.new(
        :user_id => current_user.id,
        :name => params[:dataset][:name]
      ).save
      redirect_to :datasets
    end
  end

  def index
    if user_signed_in?
      @datasets = current_user.datasets
    end
  end

end
