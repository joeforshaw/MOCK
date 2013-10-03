class RunsController < ApplicationController

  def new
    # ``
  end

  def index
    if user_signed_in?
      @datasets = current_user.datasets
      @runs = current_user.runs
    end
  end

end
