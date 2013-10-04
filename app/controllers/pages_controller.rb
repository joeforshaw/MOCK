class PagesController < ApplicationController

  def home
    gon.dataset_path = "#{dataset_path(Dataset.first.id)}.csv"
  end

end
