class PagesController < ApplicationController

  def home
    gon.dataset_path = "#{dataset_path(1)}.csv"
  end

end
