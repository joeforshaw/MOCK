class RunsController < ApplicationController

  def index
    if user_signed_in?
      @runs = current_user.runs
    end
  end

end
