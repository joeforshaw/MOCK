class DatasetsController < ApplicationController

  def new
  end

  def index
    if user_signed_in?
      @datasets = current_user.datasets
    end
  end

end
