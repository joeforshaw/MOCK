class ClustersController < ApplicationController

  before_filter :authenticate_user!

  def show
    @cluster = Cluster.find(params[:id])
  end

end
