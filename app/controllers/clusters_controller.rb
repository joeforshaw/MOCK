class ClustersController < ApplicationController

  def show
    @cluster = Cluster.find(params[:id])
  end

end
